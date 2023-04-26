require 'active_support/core_ext/integer/time'

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = false

  # Eager loading loads your whole application. When running a single test locally,
  # this probably isn't necessary. It's a good idea to do in a continuous integration
  # system, or in some way before deploying your code.
  config.eager_load = ENV['CI'].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory
  # config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.i18n.raise_on_missing_translations = true

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise
  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # TODO: I think the stuff below this line needs to go into initializers that won't
  # get overwritten when running rails app:update

  # sharethis url needs to be different from the production url
  config.sharethis_url = 'http://w.sharethis.com/button/buttons.js'

  # Just for testing mailers
  config.action_mailer.default_url_options = { host: 'http://localhost:3000' }

  config.web_host = 'http://localhost:3000'

  # This is now needed to load some of the factories because of the bigdecimal values
  # in the factories, and because Psych has made changes to not allow loading some values by default.
  config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, BigDecimal]

  config.pinterest_api_url = 'https://api-sandbox.pinterest.com/v5'
end
