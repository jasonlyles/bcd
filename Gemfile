# frozen_string_literal: true

source 'http://rubygems.org'

ruby '3.1.3'

gem 'rails', '7.0.4'

gem 'activerecord-session_store'
gem 'addressable'
gem 'amazing_print', require: 'ap'
gem 'audited'
gem 'aws-sdk-rails'
gem 'aws-sdk-s3'
gem 'aws-sdk-ses'
gem 'bootsnap', require: false
gem 'carrierwave'
gem 'cookies_eu'
gem 'devise'
gem 'docx'
gem 'exception_notification'
gem 'ffi'
gem 'fog-aws'
gem 'hpricot'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'kaminari'
gem 'mini_magick'
gem 'nested_form'
gem 'oj'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-twitter2'
gem 'pg'
gem 'rack-protection'
gem 'rake'
gem 'ransack'
gem 'rexml'
gem 'roboto'
gem 'ruby_parser'
gem 'sidekiq'
gem 'sidekiq-cron'
# gem 'sidekiq-status' Want to use this, but it's not currently working with Sidekiq 7
gem 'sitemap_generator'
gem 'twitter'

# assets
gem 'asset_sync'
gem 'bootstrap', '~> 4.1'
gem 'sass-rails'
gem 'sprockets-rails'
gem 'uglifier'

gem 'puma'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
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
end

group :profile do
  gem 'ruby-prof'
end

group :production, :staging do
  gem 'lograge'
end
