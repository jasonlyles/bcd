require_relative 'boot'
require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BrickCity
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Settings in config/environments/* take precedence over those specified here.

    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # rails app:update removed all these configs, possibly moving them to initializers?
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_lib(ignore: %w[generators tasks])

    # This might cause trouble:
    config.add_autoload_paths_to_load_path = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.default_locale = :en

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Enable the asset pipeline
    # config.assets.enabled = true

    config.active_support.cache_format_version = 7.1

    # TODO: I think the stuff below this line needs to go into initializers that won't
    # get overwritten when running rails app:update

    config.assets.precompile += ['ie.css', 'admin.css']

    config.active_job.queue_adapter = :sidekiq

    config.sales_sources = %i[brick_city_depot ebay bricklink etsy]

    ActionView::Base.field_error_proc = proc do |html_tag, instance|
      if html_tag =~ /^<label/
        %(#{html_tag}).html_safe
      else
        %(<span class="field_with_errors">#{html_tag}<label for="#{instance.send(:tag_id)}" class="message"> #{instance.error_message.first}</label></span>).html_safe
      end
    end

    config.generators do |g|
      g.test_framework :rspec, fixture: true, views: false
      g.integration_tool :rspec, fixture: true, views: true
    end

    # Send errors to our own defined routes instead of the public static html pages.
    config.exceptions_app = routes
  end
end
