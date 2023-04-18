Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter2, Rails.application.credentials.twitter.oauth2_client_id, Rails.application.credentials.twitter.oauth2_client_secret, callback_path: '/auth/twitter/callback', scope: 'tweet.read users.read', name: :twitter
  provider :facebook, Rails.application.credentials.facebook.app_id, Rails.application.credentials.facebook.secret, scope: 'email', auth_type: 'reauthenticate'
  provider :etsy, Rails.application.credentials.etsy.api_key, Rails.application.credentials.etsy.shared_secret, response_type: 'code', callback_path: '/auth/etsy/callback', scope: %w[email_r], client_id: Rails.application.credentials.etsy.api_key
end
