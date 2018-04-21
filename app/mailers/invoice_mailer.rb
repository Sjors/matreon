# Preview: http://localhost:3000/rails/mailers/invoice_mailer/new_invoice.html
class InvoiceMailer < ApplicationMailer
  before_action { @invoice = params[:invoice] }

  default to: -> { @invoice.user.email }
 
  def new_invoice
    mail subject: "Matreon invoice #{@invoice.created_at.strftime("%Y-%m")}"
  end
end
