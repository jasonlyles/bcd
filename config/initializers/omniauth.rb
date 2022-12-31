Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, Rails.application.credentials.twitter.api_key, Rails.application.credentials.twitter.secret, { authorize_params: { force_login: true } }
  provider :facebook, Rails.application.credentials.facebook.app_id, Rails.application.credentials.facebook.secret, scope: 'email', auth_type: 'reauthenticate'
end
