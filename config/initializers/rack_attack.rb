class Rack::Attack
  Rack::Attack.cache.store = Rails.cache

  ### 1. Safelists ###
  safelist('allow-localhost') do |req|
    ['127.0.0.1', '::1'].include?(req.ip)
  end

  ### 2. Custom Responses ###
  self.throttled_responder = lambda do |_env|
    [429, { 'Content-Type' => 'text/plain' }, ["Too many requests.\n"]]
  end

  self.blocklisted_responder = lambda do |_env|
    [403, { 'Content-Type' => 'text/plain' }, ["Forbidden.\n"]]
  end
end
