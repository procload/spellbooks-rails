require 'sidekiq'

redis_config = if Rails.env.production?
  { url: ENV['REDIS_URL'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 5,
    pool_timeout: 5 }
else
  { url: 'redis://localhost:6379/1' }
end

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