require 'redis'
require 'connection_pool'

redis_config = if Rails.env.production?
  {
    url: ENV.fetch('REDIS_URL'),
    ssl: true,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    timeout: 5,
    connect_timeout: 5,
    reconnect_attempts: 3,
    retry_interval: 0.5
  }
else
  {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
    timeout: 5,
    connect_timeout: 5
  }
end

$redis = ConnectionPool.new(size: 5, timeout: 5) do
  Redis.new(redis_config)
end

begin
  $redis.with do |redis|
    redis.ping
    Rails.logger.info "Successfully connected to Redis"
  end
rescue Redis::BaseConnectionError => e
  Rails.logger.error "Failed to connect to Redis: #{e.message}"
  Rails.error.report(e, handled: true)
  raise if Rails.env.production?
end

Redis.silence_deprecations = true if defined?(Redis.silence_deprecations) 