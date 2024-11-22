source "https://rubygems.org"
ruby "3.3.5"

gem "rails", "8.0.0.rc2"
gem "propshaft"
gem "pg", "~> 1.5"  # PostgreSQL is required for Heroku
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

group :production do
  # AWS S3 and Image Processing - only needed in production
  gem "aws-sdk-s3", require: false
  gem "image_processing", "~> 1.2"
  gem "active_storage_validations"
  gem "ruby-vips", ">= 2.1.0"

  # PDF Generation - only needed in production
  gem 'wicked_pdf'
  gem 'wkhtmltopdf-binary'
end

# OpenAI can be loaded on-demand
gem 'ruby-openai', require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem 'factory_bot_rails'
  gem 'dotenv-rails'
  gem "sqlite3", ">= 2.1"  # Move sqlite3 to development/test only
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