client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['BCD_TWITTER_KEY']
  config.consumer_secret = ENV['BCD_TWITTER_SECRET']
  config.access_token = ENV['BCD_OAUTH_TOKEN']
  config.access_token_secret = ENV['BCD_OAUTH_SECRET']
end