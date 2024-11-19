require 'redis'

redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')

$redis = if Rails.env.production?
  Redis.new(
    url: redis_url,
    ssl: true,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  )
else
  Redis.new(url: redis_url)
end 