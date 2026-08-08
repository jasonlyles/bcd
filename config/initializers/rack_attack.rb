class Rack::Attack
  Rack::Attack.cache.store = Rails.cache

  ### 1. Safelists ###
  safelist('allow-localhost') do |req|
    ['127.0.0.1', '::1'].include?(req.ip)
  end

  # Expanded static assets list
  safelist('allow-assets') do |req|
    req.path =~ %r{\.(css|js|png|jpg|jpeg|gif|svg|webp|avif|ico|woff|woff2|ttf|otf|eot|map)$}i
  end

  ### 2. Blocklist (Fail2Ban for Vulnerability Scanners) ###
  blocklist('block-exploit-seekers') do |req|
    Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 1.hour) do
      # Target common cms/admin paths or file extension scans directly
      req.path =~ %r{^/(wp-admin|wp-login|wp-content|phpmyadmin|\.env|\.git|config/|xmlrpc\.php)}i ||
        req.path =~ %r{\.(php|asp|aspx|jsp|cgi|env|bak|sql|config)$}i ||
        req.path.include?('..') # Catches basic path traversal attempts
    end
  end

  ### 3. Throttles ###
  # Slightly relaxed burst limit for modern browser parallel downloads / Turbo transitions
  throttle('req/ip/burst', limit: 30, period: 2.seconds) do |req|
    req.ip
  end

  # Sustained request limit per minute
  throttle('req/ip/sustained', limit: 100, period: 1.minute) do |req|
    req.ip
  end

  # Contact Form POST throttling
  throttle('contact_form/ip', limit: 5, period: 1.minute) do |req|
    req.ip if req.path == '/contact' && req.post?
  end

  ### 4. Custom Responses ###
  self.throttled_responder = lambda do |_env|
    [429, { 'Content-Type' => 'text/plain' }, ["Too many requests.\n"]]
  end

  self.blocklisted_responder = lambda do |_env|
    [403, { 'Content-Type' => 'text/plain' }, ["Forbidden.\n"]]
  end
end

ActiveSupport::Notifications.subscribe('rack_attack.rack_attack') do |_name, _start, _finish, _request_id, payload|
  req = payload[:request]
  Rails.logger.warn "[Rack::Attack][#{req.env['rack.attack.match_type']}] IP: #{req.ip} Path: #{req.path}" if %i[throttle blocklist].include?(req.env['rack.attack.match_type'])
end
