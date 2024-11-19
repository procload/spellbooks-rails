require 'sidekiq'

redis_config = {
  url: ENV.fetch('REDIS_URL') { 'redis://127.0.0.1:6379/0' },
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
  reconnect_attempts: 3,
  timeout: 5
}.compact

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

# Enable Sidekiq logging in development
if Rails.env.development?
  Sidekiq.logger.level = Logger::DEBUG
end 