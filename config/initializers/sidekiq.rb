require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL') { ENV['SIDEKIQ_REDIS_URL'] },
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    reconnect_attempts: 3
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL') { ENV['SIDEKIQ_REDIS_URL'] },
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    reconnect_attempts: 3
  }
end