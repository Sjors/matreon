class ContributionsController < ApplicationController
  before_action :authenticate_user!

  def show
    @contribution = current_user.contribution
    render json: @contribution
  end
end
