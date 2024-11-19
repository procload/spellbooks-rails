require 'sidekiq'

redis_url = ENV.fetch('REDIS_URL') { ENV['SIDEKIQ_REDIS_URL'] }
# Convert URL to TLS if needed
redis_url = redis_url.to_s.gsub('redis://', 'rediss://') if ENV['REDIS_TLS_URL'].present?

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    reconnect_attempts: 3,
    size: 10
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    reconnect_attempts: 3,
    size: 5
  }
end