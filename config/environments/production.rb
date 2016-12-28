BrickCity::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.web_host = 'https://brickcitydepot.com'

  #sharethis url needs to be different from the production url
  config.sharethis_url = "https://ws.sharethis.com/button/buttons.js"

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  #config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  config.log_level = :info
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  #Using the cloudfront name until I can get prod deployed, switch DNS providers, and get my cname set up again
  config.action_controller.asset_host = "d1f3s1yrq7p474.cloudfront.net"#"assets.brickcitydepot.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Devise needs a default url
  config.action_mailer.default_url_options = { :host => 'brickcitydepot.com' }

  #Set to use Amazon ses via aws-sdk gem
  config.action_mailer.delivery_method = :aws_sdk

  #Compress JS and CSS
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  #Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  config.cache_classes = true

  config.assets.initialize_on_precompile = true

  #Generate digests for assets URLs
  config.assets.digest = true

  #Version of the assets. Change this to expire all assets
  config.assets.version = '1.0'

  config.eager_load = true

  #Force SSL
  config.force_ssl = true
end

BrickCity::Application.config.middleware.use ExceptionNotification::Rack,
                                             :email => {
                                              :sender_address => %{"BrickCityDepot Exception" <service@brickcitydepot.com>},
                                              :exception_recipients => ["lylesjt@gmail.com"]
                                             }
