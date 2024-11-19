require 'redis'

redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')

$redis = Redis.new(
  url: redis_url,
  ssl_params: Rails.env.production? ? { verify_mode: OpenSSL::SSL::VERIFY_NONE } : nil,
  ssl: Rails.env.production?
) 