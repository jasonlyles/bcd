require_relative 'boot'
require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BrickCity
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.

    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # rails app:update removed all these configs, possibly moving them to initializers?
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W[#{config.root}/lib]
    # config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.eager_load_paths += %W[#{config.root}/lib]
    config.eager_load_paths += Dir["#{config.root}/lib/**/"]

    # This might cause trouble:
    config.add_autoload_paths_to_load_path = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.default_locale = :en

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Enable the asset pipeline
    # config.assets.enabled = true

    # TODO: I think the stuff below this line needs to go into initializers that won't
    # get overwritten when running rails app:update

    config.assets.precompile += ['ie.css', 'admin.css']

    config.active_job.queue_adapter = :sidekiq

    # Running rails app:update removed these things from the config I added when
    # moving to Rails 5.0. Adding them back, commented out, in case I need them.
    # It may have moved them out to initializers. Will have to check.
    # New config values for Rails 5:
    # Probably don't need this, but if the app needs some autoloading in prod for
    # things that work in dev, set:
    # Rails.application.config.enable_dependency_loading = true
    # belongs_to will now trigger a validation error by default if the association
    # is not present. This can be turned off per-association with optional: true.
    # config.active_record.belongs_to_required_by_default = true
    # forms in your application will each have their own CSRF token that is specific
    # to the action and method for that form.
    # config.action_controller.per_form_csrf_tokens = true
    # You can now configure your application to check if the HTTP Origin header
    # should be checked against the site's origin as an additional CSRF defense.
    # config.action_controller.forgery_protection_origin_check = true
    # The default mailer queue name is mailers. This configuration option allows
    # you to globally change the queue name.
    # config.action_mailer.deliver_later_queue_name = :new_queue_name
    # determine whether your Action Mailer views should support caching.
    # config.action_mailer.perform_caching = true
    # When using Ruby 2.4, you can preserve the timezone of the receiver when calling to_time.
    # ActiveSupport.to_time_preserves_timezone = false

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
