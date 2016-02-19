source 'http://rubygems.org'

ruby '2.1.8'

gem 'rails', '4.0.13'
gem 'activerecord-session_store'
gem 'protected_attributes'
gem 'devise', '3.2.4'
gem 'aws-s3', :require => "aws/s3", github: 'thomasdavis/aws-s3'
gem 'aws-ses', :require => "aws/ses"
gem 'omniauth'
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
gem "haml-rails"
gem 'jquery-rails'
gem 'rake'

gem 'resque'
gem 'resque_mailer'
gem 'resque-status'
gem 'heroku-api'
gem 'roboto'
gem 'sitemap_generator'

#assets
gem 'sass-rails'
gem 'compass-rails'
gem 'compass-blueprint'
gem 'coffee-rails'
gem 'uglifier'
gem 'sprockets', '2.11.0'
gem 'asset_sync'

# Use unicorn as the web server
#gem 'unicorn'
gem 'thin'
# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
# TODO: Need to spend time upgrading devise and rspec separately
group :development, :test do
  gem 'dotenv-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rb-fsevent', :require => false #if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-livereload'
  gem 'guard-compass', :require => false
  gem 'rack-mini-profiler'
  gem 'sqlite3'
  gem "nifty-generators"
  gem 'guard-rspec'
  gem "factory_girl_rails"
  gem "factory_girl_generator"
  gem "rspec-rails", '2.14.2'
  #gem 'rspec-activemodel-mocks'  # Uncomment this after upgrading rspec
  gem 'simplecov', :require => false
  #gem 'brakeman'
  gem 'metric_fu'
  gem 'mail_view', "~> 2.0.4"
  gem 'foreman'
  #gem 'sprockets_better_errors' # This seems to have stopped working. I won't need it once I get to 4.1 anyways
  gem 'awesome_print', require: 'ap'
  gem 'pry-byebug'
  gem 'bullet'
  gem 'gemsurance'
  gem 'pry'
end

group :test do
  gem 'mock_redis'
end

group :profile do
  gem 'ruby-prof'
end

group :production, :staging do
  gem 'rails_12factor'
  #best to keep this at the bottom:
  gem 'newrelic_rpm'
end
