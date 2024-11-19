require 'sidekiq'

redis_config = if Rails.env.production?
  {
    url: ENV.fetch('REDIS_URL'),
    ssl: true,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 5,
    pool_timeout: 5,
    reconnect_attempts: 3,
    size: 7  # Pool size for Sidekiq client
  }
else
  {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
    size: 5
  }
end

Sidekiq.configure_server do |config|
  config.redis = redis_config.merge(size: 12) # Larger pool for server
  config.logger.level = Logger::INFO
  
  config.on(:startup) do
    Rails.logger.info "Sidekiq server starting..."
  end
  
  config.on(:shutdown) do
    Rails.logger.info "Sidekiq server shutting down..."
  end

  config.error_handlers << Proc.new do |ex, ctx_hash|
    Rails.logger.error "Sidekiq error: #{ex.message}"
    Rails.error.report(ex, handled: true, context: ctx_hash)
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end 