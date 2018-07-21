class Invoice < ApplicationRecord
  belongs_to :user

  default_scope { order(created_at: :desc) }

  before_create :create_lightning_charge_invoice
  before_update :update_lightning_charge_invoice

  def as_json(options = nil)
    super({ only: [:id, :amount, :paid_at, :status, :created_at, :polled_at] }.merge(options || {})).merge({url: url})
  end

  def url
    return nil if !charge_invoice_id
    return "#{ ENV["LIGHTNING_CHARGE_URL"] || ENV['HOSTNAME'] }/checkout/#{ charge_invoice_id}"
  end

  def poll!
    return false if !charge_invoice_id
    return false if status != "unpaid"

    lightning_charge_invoice = LightningChargeService.find(charge_invoice_id)

    self.update!({
      status: lightning_charge_invoice.status,
      polled_at: Time.current,
      paid_at: lightning_charge_invoice.status == 'paid' ? Time.current : nil
    })

    return true
  end

  def self.generate!
    Contribution.non_zero.each do | contribution |
      contribution.create_or_update_invoice!
    end
  end

  def email!
    InvoiceMailer.with(invoice: self).new_invoice.deliver_now
    self.update emailed_at: Time.current
  end

  def self.email_unpaid_once!
    self.where(status: "unpaid", emailed_at: nil).where.not(charge_invoice_id: nil).each do |invoice|
      invoice.email!
    end
  end

  private

  def create_lightning_charge_invoice
    lightning_charge_invoice = LightningChargeService.create(amount)

    self.charge_invoice_id = lightning_charge_invoice.id
    self.status = lightning_charge_invoice.status
    self.polled_at = Time.current
  end

  def update_lightning_charge_invoice
    if amount_changed? # Create new lightning invoice
      create_lightning_charge_invoice
    end
  end

  def self.poll_unpaid!
    Invoice.where(paid_at: nil, status: 'unpaid').each do |invoice|
      invoice.poll!
    end
  end
end
