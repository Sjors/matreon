
class InvoiceMailerPreview < ActionMailer::Preview
  def new_invoice
    InvoiceMailer.with(invoice: Invoice.last).new_invoice
  end
end
