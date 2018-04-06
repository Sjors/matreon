# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @contribution_props = {contribution: current_user ? current_user.contribution : nil}
    @invoices_props = {invoices: current_user ? current_user.invoices : []}

    @layout_props = { 
      isLoggedIn: current_user.present?,
      isContributor: current_user && current_user.contribution.amount > 0,
      contributorCount: Contribution.active_count   
    }
  end
end
