class InvoicesController < ApplicationController
  before_action :authenticate_user!

  # GET /invoices.json
  def index
    # Poll most recent unpaid invoice
    if current_user.invoices.count > 0 && current_user.invoices.last.status == "unpaid" && current_user.invoices.last.polled_at < 10.seconds.ago
      current_user.invoices.last.poll!
    end

    @invoices = current_user.invoices
    render json: {invoices: @invoices}
  end
end
