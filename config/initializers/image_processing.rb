Rails.application.configure do
  # Use vips for better performance
  config.active_storage.variant_processor = :vips
  
  # Configure default URL options for Active Storage
  config.active_storage.resolve_model_to_route = :rails_storage_proxy
end 