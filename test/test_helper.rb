ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"
require "minitest/autorun"

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def sign_in_as(user)
    post session_path, params: { email_address: user.email_address, password: 'password123' }
  end
end

class ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers
  include ActiveJob::TestHelper

  def default_url_options
    { host: "localhost", port: 3000 }
  end

  def sign_in_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end

# Configure Action Cable for tests
module ActionCable
  module Connection
    class TestCase
      include ActionCable::TestHelper
    end
  end
end

Rails.application.configure do
  config.action_cable.disable_request_forgery_protection = true
end

# Configure Active Job for tests
ActiveJob::Base.queue_adapter = :test
