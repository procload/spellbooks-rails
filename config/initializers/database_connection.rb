Rails.application.config.after_initialize do
  ActiveRecord::Base.connection_pool.disconnect!

  ActiveSupport.on_load(:active_record) do
    config = Rails.application.config.database_configuration[Rails.env]
    config['pool'] = ENV['DB_POOL'] || 5
    config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
    config['checkout_timeout'] = ENV['DB_TIMEOUT'] || 5
    ActiveRecord::Base.establish_connection(config)
  end
end
