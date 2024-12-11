source "https://rubygems.org"
ruby "3.3.5"

gem "rails", "8.0.0.1"
gem "propshaft"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bcrypt", "~> 3.1.7"
gem "tzinfo-data"
gem "bootsnap", require: false

# Redis and Sidekiq
gem 'redis', '~> 5.3.0'
gem 'sidekiq'
gem 'connection_pool'

# Core functionality gems
gem 'pundit'
gem "tailwindcss-rails", "~> 3.0"
gem 'redcarpet'

# File handling and validation
gem "active_storage_validations"
gem "image_processing", "~> 1.2"
gem "ruby-vips", ">= 2.1.0"

# Production-only gems
group :production do
  # AWS S3
  gem "aws-sdk-s3", require: false
end

# AI features
gem 'ruby-openai', require: false
gem 'anthropic'

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem 'factory_bot_rails'
  gem 'dotenv-rails'
  gem "sqlite3", ">= 2.1"
end

group :development do
  gem "web-console"
  gem 'letter_opener'
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem 'faker'
end