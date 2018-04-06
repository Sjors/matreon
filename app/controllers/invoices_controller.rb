class InvoicesController < ApplicationController
  before_action :authenticate_user!

  # GET /invoices.json
  def index
    @invoices = current_user.invoices
    render json: @invoices
  end
end
