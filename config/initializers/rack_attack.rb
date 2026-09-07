class Rack::Attack
  Rack::Attack.cache.store = Rails.cache

  ### 1. Safelists ###
  safelist('allow-localhost') do |req|
    ['127.0.0.1', '::1'].include?(req.ip)
  end

  blocklist('block-exploit-seekers') do |req|
    # Exclude safelisted extensions first
    next false if req.path =~ %r{\.(css|js|png|jpg|jpeg|gif|svg|webp|avif|ico|woff|woff2|ttf|otf|eot|map)$}i

    req.path =~ %r{^/(wp-admin|wp-login|wp-content|phpmyadmin|\.env|\.git|config/|xmlrpc\.php)}i ||
      req.path =~ %r{\.(php|asp|aspx|jsp|cgi|env|bak|sql|config)\b}i ||
      req.path.include?('..')
  end

  blocklist('Cloudflare WAF bypass') do |req|
    # Skip in development and test environments so local dev doesn't get blocked
    next false unless Rails.env.production?

    # Block any request reaching Heroku that lacks Cloudflare's signature header
    req.env['HTTP_CF_RAY'].blank?
  end

  ### 4. Custom Responses ###
  self.throttled_responder = lambda do |_env|
    [429, { 'Content-Type' => 'text/plain' }, ["Too many requests.\n"]]
  end

  self.blocklisted_responder = lambda do |_env|
    [403, { 'Content-Type' => 'text/plain' }, ["Forbidden.\n"]]
  end
end
