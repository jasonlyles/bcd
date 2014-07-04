if ENV["BCD_REDISCLOUD_URL"]
  $redis = Redis.new(:url => ENV["BCD_REDISCLOUD_URL"])
end