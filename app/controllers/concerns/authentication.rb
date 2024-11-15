module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session.present?
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      if session_record = Session.find_by(id: session[:current_session_id])
        Current.session = session_record
        Current.user = session_record.user
      end
    end

    def find_session_by_cookie
      if session_record = Session.find_by(id: cookies.signed[:session_id])
        Current.session = session_record
        Current.user = session_record.user
      end
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path, notice: 'Please sign in to continue.'
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def require_teacher
      unless Current.user&.teacher?
        redirect_to root_path, alert: "You must be a teacher to access this area"
      end
    end

    def require_student
      unless Current.user&.student?
        redirect_to root_path, alert: "You must be a student to access this area"
      end
    end

    def start_new_session_for(user)
      session_record = user.sessions.create!
      session[:current_session_id] = session_record.id
      Current.session = session_record
      Current.user = user
    end

    def terminate_session
      Current.session&.destroy
      cookies.delete(:session_id)
      Current.reset
    end

    def authenticate_user
      if authenticated_user = Current.session&.user
        Current.user = authenticated_user
      else
        redirect_to new_session_path, alert: "Please sign in to continue."
      end
    end
end
