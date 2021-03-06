# frozen_string_literal: false

source 'https://rubygems.org'
ruby '2.4.2'

# Networking gems
gem 'http'

# Asynchronicity gems
gem 'concurrent-ruby'

# Parallel worker gems
gem 'aws-sdk-sqs', '~> 1'
gem 'faye', '~> 1'
gem 'shoryuken', '~> 3'

# Web app related
gem 'econfig'
gem 'pry' # to run console in production
gem 'puma'
gem 'rake' # to run migrations in production
gem 'roda'
gem 'rack-cors', :require => 'rack/cors'

# Database related
gem 'hirb'
gem 'sequel'

# Data gems
gem 'dry-struct'
gem 'dry-types'

# Google map api
gem 'google_maps_service'
gem 'geocoder'

# Representers
gem 'multi_json'
gem 'roar'

# Services
gem 'dry-monads'
gem 'dry-transaction'



group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'rack-test'
  gem 'simplecov'
  gem 'vcr'
  gem 'webmock'
end

group :development, :test do
  gem 'sqlite3'

  gem 'database_cleaner'

  gem 'rerun'

  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end

group :production do
  gem 'pg'
end
