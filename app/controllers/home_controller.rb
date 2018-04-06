# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @layout_props = { 
      isLoggedIn: current_user.present?,
      isContributor: current_user && current_user.contribution.amount > 0,
      contributorCount: Contribution.active_count   
    }
  end
end
