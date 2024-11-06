require 'sidekiq'

redis_config = if Rails.env.production?
  redis_url = ENV['SIDEKIQ_REDIS_URL'] || ENV['REDIS_TLS_URL'] || ENV['REDIS_URL']
  
  {
    url: redis_url,
    ssl_params: { 
      verify_mode: OpenSSL::SSL::VERIFY_NONE 
    },
    network_timeout: 5,
    pool_timeout: 5,
    reconnect_attempts: 3,
    ssl: true
  }
else
  { url: 'redis://localhost:6379/1' }
end

# Log the Redis URL being used (with credentials removed)
if Rails.env.production?
  sanitized_url = redis_config[:url].gsub(/\/\/.*@/, '//[FILTERED]@')
  puts "Connecting to Redis at: #{sanitized_url}"
end

Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.logger.level = Logger::INFO # Change from DEBUG to reduce noise
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end 