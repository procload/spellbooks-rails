class HomeController < ApplicationController
  allow_unauthenticated_access only: [:index]
  
  def index
    @assignments = Assignment.order(created_at: :desc).limit(3)
  end
end