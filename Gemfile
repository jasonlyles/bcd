# frozen_string_literal: true

source 'http://rubygems.org'

ruby '3.1.3'

gem 'rails', '7.0.4'

gem 'activerecord-session_store'
gem 'addressable'
gem 'audited'
gem 'awesome_print', require: 'ap'
gem 'aws-sdk-rails'
gem 'aws-sdk-s3'
gem 'aws-sdk-ses'
gem 'bootsnap', require: false
gem 'carrierwave'
gem 'devise'
gem 'exception_notification'
gem 'ffi'
gem 'fog-aws'
gem 'hpricot'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'json'
gem 'kaminari'
gem 'mini_magick'
gem 'nested_form'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'pg'
gem 'platform-api' # For Heroku's API
gem 'rack-protection'
gem 'rake'
gem 'ransack'
gem 'resque'
gem 'resque_mailer'
gem 'roboto'
gem 'ruby_parser'
gem 'sinatra'
gem 'sitemap_generator'
gem 'twitter'

# assets
gem 'asset_sync'
gem 'bootstrap', '~> 4.1'
gem 'sass-rails'
gem 'sprockets-rails'
gem 'uglifier'

gem 'thin'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'foreman'
  gem 'listen'
  gem 'mail_view'
  gem 'nifty-generators'
  gem 'pry-rails'
  # gem 'rack-mini-profiler'
  gem 'rails-controller-testing'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-rails'
  gem 'simplecov'

  # Specifically adding these 4 gems gets some warnings to go away. Will try once I get
  # to Rails 7 to remove these.
  # gem 'net-http'
  # gem 'net-imap'
  # gem 'net-smtp'
  # gem 'uri', '0.10.0'

  # code quality gems
  gem 'brakeman'
  gem 'fasterer'
  gem 'overcommit'
  gem 'rails_best_practices'
  gem 'reek'
  gem 'rubocop'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'database_cleaner'
  gem 'mock_redis'
end

group :profile do
  gem 'ruby-prof'
end

group :production, :staging do
  gem 'lograge'
  # best to keep this at the bottom:
  gem 'newrelic_rpm'
end
