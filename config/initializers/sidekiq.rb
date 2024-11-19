require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL') { ENV['SIDEKIQ_REDIS_URL'] },
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 5,
    pool_timeout: 5,
    reconnect_attempts: 3
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL') { ENV['SIDEKIQ_REDIS_URL'] },
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 5,
    pool_timeout: 5,
    reconnect_attempts: 3
  }
end