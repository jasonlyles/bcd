Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['BCD_TWITTER_KEY'], ENV['BCD_TWITTER_SECRET']
  provider :facebook, ENV['BCD_FACEBOOK_APP_ID'], ENV['BCD_FACEBOOK_SECRET'], :scope => 'email'
end
