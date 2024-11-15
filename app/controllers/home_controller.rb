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

  def test_toast
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append("toasts",
          partial: "shared/toast",
          locals: { 
            type: "success",
            message: "This is a test toast message!",
            auto_hide: true
          }
        )
      end
    end
  end
end