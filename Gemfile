# frozen_string_literal: true

source 'http://rubygems.org'

ruby '2.6.10'

gem 'rails', '5.2.8'

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
gem 'ffi' # , '>= 1.9.24'
gem 'fog-aws'
gem 'hpricot'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'json' # , '2.1.0'
gem 'kaminari'
gem 'mini_magick'
gem 'nested_form'
gem 'omniauth' # , '~> 1.3'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'pg'
gem 'platform-api' # For Heroku's API
gem 'rack-protection' # , '~> 2.0'
gem 'rake'
gem 'ransack'
gem 'resque'
gem 'resque_mailer'
gem 'roboto'
gem 'ruby_parser'
gem 'sinatra' # , '~> 2.0'
gem 'sitemap_generator'
gem 'twitter'

# assets
gem 'asset_sync'
gem 'bootstrap', '~> 4.1'
gem 'sass-rails' # , '~> 5.0'
gem 'sprockets' # , '~> 3.7'
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
  gem 'mail_view' # , '~> 2.0.4'
  gem 'nifty-generators'
  gem 'pry'
  gem 'pry-byebug'
  # gem 'rack-mini-profiler'
  gem 'rails-controller-testing'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-rails' # , '~> 5.0.0'
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
  gem 'web-console' # , '~> 2.0'
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
