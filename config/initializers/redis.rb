$redis = Redis.new(url: Rails.application.credentials.redis.url) if Rails.application.credentials.redis.url
