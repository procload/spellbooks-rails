class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    if authenticated? && Current.user
      @assignments = Current.user.relevant_assignments
      render 'dashboard'
    else
      render 'landing'
    end
  end
end