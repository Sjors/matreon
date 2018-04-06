class Contribution < ApplicationRecord
  belongs_to :user

  before_save :create_or_update_invoice

  def as_json(options = nil)
    super({ only: [:amount] }.merge(options || {}))
  end

  def self.active_count
    # TODO: exclude contributors more than 1 month behind in payments
    return self.where('amount >= ?', 1).count
  end

  private

  def create_or_update_invoice
    # TODO: only consider invoice in current month
    if self.user.invoices.count > 0
      # If last invoice already paid, ignore.
      return if self.user.invoices.last.paid_at

      # If amount is unchanged, ingore
      return if self.user.invoices.last.amount == amount

      # If amount is zero, delete invoice:
      if amount == 0
        self.user.invoices.last.destroy 
        return
      end

      # Update invoice amount (this requests a new lightning invoice)
      self.user.invoices.last.update amount: amount
    else
      # requests a lightning invoice
      self.user.invoices.create(amount: amount) if amount > 0 
    end
  end
end
