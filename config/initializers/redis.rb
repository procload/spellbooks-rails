require 'redis'

redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')

begin
  $redis = if Rails.env.production?
    Redis.new(
      url: redis_url,
      ssl: true,
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
      timeout: 1,
      reconnect_attempts: 2
    )
  else
    Redis.new(
      url: redis_url,
      timeout: 1,
      reconnect_attempts: 2
    )
  end

  # Add error handling
  Redis.silence_deprecations = true if defined?(Redis.silence_deprecations)

  # Monitor Redis connection errors
  $redis.ping
rescue Redis::CannotConnectError => e
  Rails.logger.error "Failed to connect to Redis: #{e.message}"
  Rails.error.report(e, handled: true)
end 