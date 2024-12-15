require 'sidekiq'

redis_config = {
  url: ENV['REDIS_URL'],
  driver: :ruby,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
  reconnect_attempts: 3,
  timeout: 5,
  size: 5
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

# Configure global Sidekiq middleware
Sidekiq.configure_server do |config|
  config.error_handlers << proc { |ex, ctx_hash| Rails.logger.error("Sidekiq job error: #{ex.message}") }
end

# Set global Sidekiq options
Sidekiq.default_job_options = {
  'retry' => 5,
  'backtrace' => true,
  'retry_interval' => 10,  # Base retry delay in seconds
  'dead' => false  # Don't move to dead queue, keep retrying
}