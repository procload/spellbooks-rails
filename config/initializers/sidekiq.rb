require 'sidekiq'

redis_config = {
  url: ENV['REDIS_URL'],
  reconnect_attempts: 3,
  timeout: 5,
  size: 5  # Keep pool size small due to connection limit
}

Sidekiq.configure_server do |config|
  server_redis_config = redis_config.merge(
    size: 5  # Adjusted pool size for server
  )
  config.redis = server_redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end