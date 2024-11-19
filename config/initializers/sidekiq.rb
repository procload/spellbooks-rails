require 'sidekiq'

redis_config = {
  url: ENV['REDIS_URL'],  # This will use the TLS URL (port 22640)
  ssl: true,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
  reconnect_attempts: 3,
  timeout: 5,
  size: 5  # Keep pool size small since we have a 20 connection limit
}

Sidekiq.configure_server do |config|
  server_redis_config = redis_config.merge(
    size: 7  # Larger pool for server
  )
  config.redis = server_redis_config 
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end