# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'simplecov'
require 'mock_redis'
SimpleCov.start 'rails' do
  add_filter 'app/uploaders/'
  add_filter 'vendor/gems/'
  add_filter 'lib/http_accept_language.rb'
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Resque.redis = MockRedis.new

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.raise_errors_for_deprecations!

  config.after(:all) do
    #Clean up test artifacts
    if Rails.env.test? || Rails.env.cucumber?
      FileUtils.rm_rf(Dir["#{Rails.root}/public/pdfs/test/[^.]*"])
      FileUtils.rm_rf(Dir["#{Rails.root}/public/uploads/tmp/[^.]*"])
      FileUtils.rm_rf(Dir["#{Rails.root}/public/carrierwave/[^.]*"])
    end
  end
end
