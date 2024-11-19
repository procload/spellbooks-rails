require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
  config.logger.level = Logger::DEBUG
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end

# Enable Sidekiq logging in development
if Rails.env.development?
  Sidekiq.logger.level = Logger::DEBUG
end 