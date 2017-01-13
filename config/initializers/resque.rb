require 'resque/status_server'
Resque.redis = ENV["REDISCLOUD_URL"]
Resque::Server.tabs << 'BCD Admin'
Resque::Plugins::Status::Hash.expire_in = (24 * 60 * 60)
Resque.logger.level = Logger::DEBUG