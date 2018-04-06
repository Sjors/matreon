# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @layout_props = { isLoggedIn: current_user.present? }
  end
end
