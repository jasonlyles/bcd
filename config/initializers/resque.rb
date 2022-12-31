Resque.redis = Rails.application.credentials.redis.url
# TODO: Figure out how to get the tab back.
# Resque::Server.tabs << 'BCD Admin'
Resque.logger.level = Logger::DEBUG
