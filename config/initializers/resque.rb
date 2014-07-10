require 'resque/server'
Resque.redis = ENV["REDISCLOUD_URL"]
Resque::Server.tabs << 'BCD Admin'