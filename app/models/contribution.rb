class Contribution < ApplicationRecord
  belongs_to :user

  before_save :create_or_update_invoice!

  scope :non_zero, -> { where('amount >= ?', 1) }

  def as_json(options = nil)
    super({ only: [:amount] }.merge(options || {}))
  end

  def self.active_count
    # TODO: exclude contributors more than 1 month behind in payments
    return self.non_zero.count
  end

  def create_or_update_invoice!
    # TODO: only consider invoice in current month
    if self.user.invoices.this_month.count > 0
      # If last invoice already paid, ignore.
      return if self.user.invoices.this_month.last.paid_at

      # If amount is unchanged, ingore
      return if self.user.invoices.this_month.last.amount == amount

      # If amount is zero, delete invoice:
      if amount == 0
        self.user.invoices.this_month.last.destroy 
        return
      end

      # Update invoice amount (this requests a new lightning invoice)
      self.user.invoices.this_month.last.update amount: amount
    else
      # requests a lightning invoice
      self.user.invoices.create(amount: amount) if amount > 0 
    end
  end
end
