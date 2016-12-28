BrickCity::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.web_host = 'http://localhost:3000'

  #sharethis url needs to be different from the production url
  config.sharethis_url = "http://w.sharethis.com/button/buttons.js"

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  #config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Devise needs a default url
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # Set to catch mail via mailcatcher
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {address: 'localhost', port: 1025}

  #Do not compress assets
  config.assets.js_compressor = :uglifier

  #Expands the lines which load the assets
  config.assets.debug = true

  config.eager_load = false

  #For sprockets_better_errors gem, to show in dev mode sprocket errors that would normally only show up in prod.
  # I believe the changes you get in this gem show up in Rails 4.1, so this is probably only temporary
  config.assets.raise_production_errors = true

  #config.action_controller.asset_host = "http://images.brickcitydepot.com" #Just set this up to test whether I had it working or not. It works
=begin
  config.after_initialize do
    Bullet.enable
    Bullet.alert
    Bullet.bullet_logger
    Bullet.console
    Bullet.rails_logger
    Bullet.raise
  end
=end
end

#For troubleshooting exception notifications:
=begin
BrickCity::Application.config.middleware.use ExceptionNotification::Rack,
                                              :email => {
                                                :sender_address => %{"BrickCityDepot Exception" <service@brickcitydepot.com>},
                                                :exception_recipients => ["lylesjt@gmail.com"]
                                              }
=end
