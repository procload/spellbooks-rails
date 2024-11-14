ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "factory_bot_rails"

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
end

# Add support for integration tests
class ActionDispatch::IntegrationTest
  def sign_in_as(user)
    # Create a session record
    session_record = user.sessions.create!(
      user_agent: 'Rails Testing',
      ip_address: '0.0.0.0'
    )

    # Manually sign the session ID using Rails' message verifier
    signed_session_id = Rails.application.message_verifier(:session_id).generate(session_record.id)

    # Set the signed cookie
    # If you're using Capybara, make sure it's properly configured
    cookies[:session_id] = signed_session_id

    # Set Current.session for the duration of the test
    Current.session = session_record
  end

  def assert_require_authentication
    assert_redirected_to new_session_path
    assert_equal 'Please sign in to continue.', flash[:notice]
  end
end

# Remove or comment out this line
# FactoryBot.find_definitions
