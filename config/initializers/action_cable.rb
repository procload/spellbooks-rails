Rails.application.config.action_cable.allowed_request_origins = [
  'http://localhost:3000',
  'http://127.0.0.1:3000'
]

Rails.application.config.action_cable.mount_path = '/cable'
Rails.application.config.action_cable.disable_request_forgery_protection = true if Rails.env.development?