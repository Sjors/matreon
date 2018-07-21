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

    uri = LightningChargeService.invoice_uri(charge_invoice_id)
    request = LightningChargeService.http_request("GET", uri)

    invoice = LightningChargeService.request_and_parse(request, uri)

    self.update status: invoice["status"], polled_at: Time.current, paid_at: invoice["status"] == "paid" ? Time.current : nil
    
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
    uri = LightningChargeService.invoice_uri()

    request = LightningChargeService.http_request("POST", uri)

    request.set_form_data({
      msatoshi: amount * 1000,
      description: "Matreon",
      expiry: 60 * 60 * 24 * 7 # 1 week, TODO: add invoices.expires_at
    })

    generated_invoice = LightningChargeService.request_and_parse(request, uri)

    self.charge_invoice_id = generated_invoice["id"]
    self.status = generated_invoice["status"]
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
