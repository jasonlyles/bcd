Resque.redis = ENV["REDISCLOUD_URL"]
# TODO: Figure out how to get the tab back.
# Resque::Server.tabs << 'BCD Admin'
Resque.logger.level = Logger::DEBUG
