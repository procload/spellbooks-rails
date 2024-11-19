require 'sidekiq'

redis_url = ENV.fetch('REDIS_URL') { 'redis://127.0.0.1:6379/0' }

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
  config.logger.level = Logger::DEBUG
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

# Enable Sidekiq logging in development
if Rails.env.development?
  Sidekiq.logger.level = Logger::DEBUG
end 