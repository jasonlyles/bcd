require 'resque/server'

Resque.redis = Rails.application.credentials.redis.url
Resque::Server.tabs << 'BCD Admin'
Resque.logger.level = Logger::DEBUG
