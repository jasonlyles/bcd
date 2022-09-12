source 'http://rubygems.org'

ruby '2.4.1'

gem 'rails', '4.2.11'
gem 'json', '1.8.5'
gem 'activerecord-session_store'
gem 'protected_attributes'
gem 'devise', '3.5.10'
gem 'aws-sdk'
gem 'aws-sdk-rails'
gem 'omniauth', '~> 1.3'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'hpricot'
gem 'ruby_parser'
gem 'carrierwave'
gem 'carrierwave_backgrounder'
gem 'fog'
gem 'pg'
gem 'mini_magick'
gem 'kaminari'
gem 'nested_form'
gem 'twitter'
gem 'exception_notification'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rake'
gem "rack-protection", ">= 1.5.5"
gem "ffi", ">= 1.9.24"
gem "ransack"
gem 'awesome_print', require: 'ap'

gem 'resque'
gem 'resque_mailer'
gem 'resque-status'
gem 'platform-api' # For Heroku's API
gem 'roboto'
gem 'sitemap_generator'
gem 'responders', '~> 2.0'

#assets
gem 'sass-rails', '~> 5.0'
gem 'uglifier'
gem 'sprockets', '~> 3.7'
gem 'asset_sync'
gem 'bootstrap', '~> 4.1'

gem 'thin'

group :development, :test do
  gem 'dotenv-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rack-mini-profiler'
  gem "nifty-generators"
  gem "factory_girl_rails"
  gem "factory_girl_generator"
  gem "rspec-rails", '~> 3.0'
  gem 'rspec-activemodel-mocks'
  gem 'simplecov', :require => false
  #gem 'brakeman'
  gem 'metric_fu', git: 'https://github.com/bergholdt/metric_fu.git'
  gem 'mail_view', "~> 2.0.4"
  gem 'foreman'
  gem 'pry-byebug'
  gem 'bullet'
  gem 'gemsurance'
  gem 'pry'
  gem 'faker'
end

group :development do
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'mock_redis'
  gem 'database_cleaner'
end

group :profile do
  gem 'ruby-prof'
end

group :production, :staging do
  gem 'rails_12factor'
  #best to keep this at the bottom:
  gem 'newrelic_rpm'
  gem 'lograge'
end
