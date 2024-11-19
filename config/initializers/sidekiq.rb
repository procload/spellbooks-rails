require 'sidekiq'

redis_config = {
  url: ENV.fetch('REDIS_URL') { 'redis://127.0.0.1:6379/0' },
  password: ENV['REDIS_PASSWORD']
}.compact

Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.logger.level = Logger::DEBUG
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

# Enable Sidekiq logging in development
if Rails.env.development?
  Sidekiq.logger.level = Logger::DEBUG
end 