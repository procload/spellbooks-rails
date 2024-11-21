class HomeController < ApplicationController
  allow_unauthenticated_access

  def test_notification
    return redirect_to root_path, alert: 'Please sign in first' unless authenticated?

    target_user_id = Current.user.id == 1 ? 2 : 1
    
    Turbo::StreamsChannel.broadcast_append_to(
      "user_#{target_user_id}_notifications",
      partial: "shared/notification",
      locals: { 
        type: "success",
        message: "Test notification from User #{Current.user.id}!",
        auto_hide: true,
        duration: 5000
      }
    )
    
    redirect_to root_path, notice: 'Notification sent!'
  end
  def index
    if authenticated? && Current.user
      @assignments = Current.user.relevant_assignments
      @stream_name = Turbo::StreamsChannel.verified_stream_name("assignments")
      render 'dashboard'
    else
      render 'landing'
    end
  end

  def test_toast
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append("notifications",
          partial: "shared/notification",
          locals: { 
            type: "success",
            message: "Test notification",
            auto_hide: true,
            duration: 5000
          }
        )
      end
    end
  end
end