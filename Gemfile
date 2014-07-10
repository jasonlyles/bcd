source 'http://rubygems.org'
source 'http://gems.github.com'

ruby '1.9.3'

gem 'rails', '4.0.5'
gem 'activerecord-session_store'
gem 'protected_attributes'
gem 'devise'
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
gem 'sprockets_better_errors'
gem 'resque'
gem 'resque_mailer'
gem 'heroku-api'
gem 'roboto'

#assets
gem 'sass-rails'
gem 'compass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'sprockets', '2.11.0'

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
  gem "rspec-rails"
  gem 'simplecov', :require => false
  #gem 'brakeman'
  gem 'metric_fu'
  gem 'mail_view', "~> 2.0.4"
  gem 'foreman'
end

group :profile do
  gem 'ruby-prof'
end

group :production, :staging do
  gem 'rails_12factor'
  #best to keep this at the bottom:
  gem 'newrelic_rpm'
end
