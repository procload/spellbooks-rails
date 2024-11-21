module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.info "[ActionCable] Connected: User #{current_user.id}"
    end

    private

    def find_verified_user
      if verified_user = env['warden'].user || find_user_from_session
        verified_user
      else
        reject_unauthorized_connection
      end
    end

    def find_user_from_session
      if session_id = cookies.encrypted[:current_session_id]
        Session.find_by(id: session_id)&.user
      end
    end

    def session
      @session ||= Session.find_by(id: cookies.encrypted[:current_session_id])
    end
  end
end
