# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @hello_world_props = { name: "Stranger" }
  end
end
