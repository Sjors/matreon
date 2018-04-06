class InvoicesController < ApplicationController
  before_action :authenticate_user!

  # GET /invoices.json
  def index
    # Poll most recent unpaid invoice
    if current_user.invoices.count > 0
      last_invoice = current_user.invoices.last
      if last_invoice.status == "unpaid" && last_invoice.polled_at < 10.seconds.ago
        last_invoice.poll!
      end
    end

    @invoices = current_user.invoices
    render json: {invoices: @invoices}
  end
end
