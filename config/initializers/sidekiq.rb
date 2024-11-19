require 'sidekiq'

redis_conn = proc {
  url = ENV.fetch('REDIS_URL', ENV['SIDEKIQ_REDIS_URL']).to_s.gsub('rediss://', 'redis://')
  Redis.new(
    url: url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    reconnect_attempts: 3
  )
}

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 5, &redis_conn)
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 25, &redis_conn)
end