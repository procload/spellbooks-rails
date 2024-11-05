class HomeController < ApplicationController
  def index
    @assignments = Assignment.order(created_at: :desc).limit(3)
  end
end 