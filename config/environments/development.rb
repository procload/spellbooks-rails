require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Make code changes take effect immediately without server restart.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing.
  config.server_timing = true

  # Enable/disable Action Controller caching. By default Action Controller caching is disabled.
  # Run rails dev:cache to toggle Action Controller caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end

  # Change to :null_store to avoid any caching.
  config.cache_store = :memory_store

  # Store uploaded files on Amazon S3
  config.active_storage.service = :amazon
  
  # Set default URL options for Active Storage
  Rails.application.routes.default_url_options[:host] = 'localhost'
  Rails.application.routes.default_url_options[:port] = 3000
  
  config.active_storage.default_url_options = {
    host: "localhost",
    port: 3000,
    protocol: 'http'
  }
  
  # Enable better logging for Active Storage
  config.active_storage.logger = ActiveSupport::Logger.new(STDOUT)
  config.active_storage.service_urls_expire_in = 5.minutes

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Make template changes take effect immediately.
  config.action_mailer.perform_caching = false

  # Set localhost to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Append comments with runtime information tags to SQL queries in logs.
  config.active_record.query_log_tags_enabled = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # Apply autocorrection by RuboCop to files generated by `bin/rails generate`.
  # config.generators.apply_rubocop_autocorrect_after_generate!

  config.assets.debug = true         # Expands the lines which load the assets
  config.assets.compile = true       # Enable dynamic asset compilation
  config.assets.digest = false       # Disable asset digests for easier debugging
  config.importmap.sweep_cache = true

  # Enable hot reloading for JavaScript and CSS
  config.assets.debug = true
  config.assets.compile = true
  config.assets.digest = false
  config.assets.quiet = false  # Add this to see asset-related logs
  config.assets.check_precompiled_asset = false  # Add this to skip checking precompiled assets
  
  # Enable cache busting for importmaps
  config.importmap.sweep_cache = true
  
  # Add this to force recompilation of assets
  config.assets.configure do |env|
    env.cache = ActiveSupport::Cache::NullStore.new
  end

  # Add this to log Turbo Stream broadcasts in development
  config.action_controller.action_on_unpermitted_parameters = :log
  config.turbo.debug_logging = true

  # Allow ActionCable requests from any origin
  # config.action_cable.disable_request_forgery_protection = true
  # config.action_cable.url = "ws://localhost:3000/cable"
  # config.action_cable.allowed_request_origins = [
  #   "http://localhost:3000",
  #   "http://127.0.0.1:3000",
  #   /http:\/\/localhost:.*/
  # ]

  # Add or update these lines:
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.perform_deliveries = true
end
