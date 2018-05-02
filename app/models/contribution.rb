class Contribution < ApplicationRecord
  belongs_to :user

  before_validation(on: :create) do
    self.billing_day_of_month = [Time.current.day, 28].min
  end

  scope :non_zero, -> { where('amount >= ?', 1) }

  def as_json(options = nil)
    super({ only: [:amount] }.merge(options || {}))
  end
  
  def subscribed_up_to
    # If user never paid an invoice, return a date far in the past:
    if user.invoices.count == 0 || (user.invoices.count == 1 && user.invoices.first.status != "paid")
      return Time.zone.local(2000, 01, 01) 
    # If most recent invoice is paid, return 1 month past the invoice date:
    elsif user.invoices.first.status == "paid"
      return user.invoices.first.created_at + 1.month
    # Return 1 month past the previous invoice date::
    else
      return user.invoices.second.created_at + 1.month
    end
  end

  def self.active_count
    # TODO: exclude contributors more than 1 month behind in payments
    return self.non_zero.count
  end

  def create_or_update_invoice!
    recent_invoice = self.user.invoices.first
    # Create an initial invoice
    if recent_invoice.nil? 
      # Only if the amount is non-zero:
      self.user.invoices.create(amount: amount) if amount > 0
    # Create an invoice on billing days, but don't create a duplicate invoice in a month:
    elsif self.billing_day_of_month == Time.current.day && !(recent_invoice.created_at.year == Time.current.year && recent_invoice.created_at.month == Time.current.month) 
      # Only if the amount is non-zero:
      self.user.invoices.create(amount: amount) if amount > 0
    # Otherwise, consider updating an existing unpaid invoice:
    else
      # If most recent invoice already paid, ignore.
      return if self.user.invoices.first.paid_at

      # If amount is unchanged, ingore
      return if self.user.invoices.first.amount == amount

      # If amount is zero, delete invoice:
      if amount == 0
        self.user.invoices.first.destroy 
        return
      end

      # Update invoice amount (this requests a new lightning invoice)
      self.user.invoices.first.update amount: amount
    end
  end
end
