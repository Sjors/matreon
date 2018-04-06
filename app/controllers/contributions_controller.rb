class ContributionsController < ApplicationController
  before_action :authenticate_user!

  # GET /contribution.json
  def show
    @contribution = current_user.contribution
    render json: @contribution
  end

  # PATCH/PUT /contribution.json
  def update
    @contribution = current_user.contribution
    if @contribution.update(contribution_params)
      render json: @contribution
    else
      render json: @contribution.errors, status: :unprocessable_entity
    end
  end

  private

  def contribution_params
    params.require(:contribution).permit(:amount)
  end
end
