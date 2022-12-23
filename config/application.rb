require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

if defined?(Bundler)
  Bundler.require(:default, Rails.env)
end

module BrickCity
  class Application < Rails::Application
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      unless html_tag =~ /^<label/
        %{<span class="field_with_errors">#{html_tag}<label for="#{instance.send(:tag_id)}" class="message"> #{instance.error_message.first}</label></span>}.html_safe
      else
        %{#{html_tag}}.html_safe
      end
    end
    config.generators do |g|
      g.test_framework :rspec, :fixture => true, :views => false
      g.integration_tool :rspec, :fixture => true, :views => true
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
     config.autoload_paths += %W(#{config.root}/lib)
     config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
     #config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # JavaScript files you want as :defaults (application.js is always included).
    #config.action_view.javascript_expansions[:defaults] = %w(jquery.js rails.js)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password,:password_confirmation]

    #Enable the asset pipeline
    config.assets.enabled = true

    config.assets.precompile += ['ie.css', 'admin.css']

    # New config values for Rails 5:
    # Once whatever deprecation warnings are gone, set this to false
    ActiveSupport.halt_callback_chains_on_return_false = true
    # Probably don't need this, but if the app needs some autoloading in prod for
    # things that work in dev, set:
    # Rails.application.config.enable_dependency_loading = true
    # belongs_to will now trigger a validation error by default if the association
    # is not present. This can be turned off per-association with optional: true.
    config.active_record.belongs_to_required_by_default = true
    # forms in your application will each have their own CSRF token that is specific
    # to the action and method for that form.
    config.action_controller.per_form_csrf_tokens = true
    # You can now configure your application to check if the HTTP Origin header
    # should be checked against the site's origin as an additional CSRF defense.
    config.action_controller.forgery_protection_origin_check = true
    # The default mailer queue name is mailers. This configuration option allows
    # you to globally change the queue name.
    # config.action_mailer.deliver_later_queue_name = :new_queue_name
    # determine whether your Action Mailer views should support caching.
    config.action_mailer.perform_caching = true
    # When using Ruby 2.4, you can preserve the timezone of the receiver when calling to_time.
    # ActiveSupport.to_time_preserves_timezone = false

    # The error raised by this is:
    # `ActionController::UnfilteredParameters: unable to convert unpermitted parameters to hash`
    # Make sure all needed params are included in the whitelist, including :_method
    # to accommodate links for deleting objects.
    config.action_controller.raise_on_unfiltered_parameters = true
  end
end
