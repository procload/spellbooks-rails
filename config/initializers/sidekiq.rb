require 'sidekiq'
require 'uri'

redis_config = if Rails.env.production?
  redis_url = ENV['REDIS_TEMPORARY_URL'] || ENV['REDIS_URL']
  uri = URI.parse(redis_url)
  
  {
    url: redis_url,
    network_timeout: 15,
    pool_timeout: 15,
    reconnect_attempts: 5,
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  }
else
  { url: 'redis://localhost:6379/1' }
end

if Rails.env.production?
  sanitized_url = redis_config[:url].gsub(/\/\/.*@/, '//[FILTERED]@')
  puts "Connecting to Redis at: #{sanitized_url}"
end

Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.logger.level = Logger::INFO
  
  # Add error handling
  config.on(:startup) do
    puts "Sidekiq server starting..."
  end
  
  config.on(:shutdown) do
    puts "Sidekiq server shutting down..."
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

# Test Redis connection on startup
if Rails.env.production?
  begin
    redis = Redis.new(redis_config)
    redis.ping
    puts "Successfully connected to Redis"
  rescue => e
    puts "Failed to connect to Redis: #{e.message}"
    puts "Redis config: #{redis_config.merge(url: '[FILTERED]').inspect}"
  end
end 