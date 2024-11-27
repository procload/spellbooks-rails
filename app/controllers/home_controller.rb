class HomeController < ApplicationController
  allow_unauthenticated_access only: [:index]

  def index
    if authenticated? && Current.user
      @assignments = Current.user.relevant_assignments
      render 'dashboard'
    else
      render 'landing'
    end
  end

  def dashboard
    unless authenticated? && Current.user
      redirect_to root_path
      return
    end

    @assignments = Current.user.relevant_assignments
    
    if params[:subject].present?
      @assignments = @assignments.where(subject: params[:subject])
    end
    
    @available_subjects = Assignment.distinct.pluck(:subject).compact
  end
end