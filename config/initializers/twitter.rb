client = Twitter::REST::Client.new do |config|
  config.consumer_key = Rails.application.credentials.twitter.api_key
  config.consumer_secret = Rails.application.credentials.twitter.secret
  config.access_token = Rails.application.credentials.oauth.token
  config.access_token_secret = Rails.application.credentials.oauth.secret
end
