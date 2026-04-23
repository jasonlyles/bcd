class Rack::Attack
  Rack::Attack.cache.store = Rails.cache

  ### 1. Safelists (Checked First) ###
  safelist('allow-localhost') do |req|
    ['127.0.0.1', '::1'].include?(req.ip)
  end

  safelist('allow-assets') do |req|
    req.path =~ %r{\.(css|js|png|jpg|jpeg|gif|svg|webp|avif|ico|woff|woff2|eot|otf)$}i
  end

  ### 2. Blocklist (Fail2Ban) ###
  blocklist('block-exploit-seekers') do |req|
    Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 1.hour) do
      # Use raw query_string to avoid Rails-level encoding errors
      qs = req.query_string.to_s
      CGI.unescape(qs) =~ %r{/etc/passwd|wp-config|wp-admin|'|"|%27|%22}i ||
        req.path =~ %r{\.(php|asp|aspx|jsp|cgi|env)$}i
    end
  end

  ### 3. Throttles ###
  # Burst Limit
  throttle('req/ip/burst', limit: 10, period: 1.second) do |req|
    req.ip
  end

  # Sustained Limit
  throttle('req/ip/sustained', limit: 100, period: 1.minute) do |req|
    req.ip
  end

  # Specific Contact Form Protection
  throttle('contact_form/ip', limit: 5, period: 1.minute) do |req|
    # Adjust path if your POST route is different
    req.ip if req.path == '/contact' && req.post?
  end

  ### 4. Custom Responses ###
  self.throttled_responder = lambda do |_env|
    [429, { 'Content-Type' => 'text/plain' }, ["Too many requests.\n"]]
  end

  self.blocklisted_responder = throttled_responder
end

ActiveSupport::Notifications.subscribe('rack_attack.rack_attack') do |_name, _start, _finish, _request_id, payload|
  req = payload[:request]
  Rails.logger.warn "[Rack::Attack][#{req.env['rack.attack.match_type']}] IP: #{req.ip} Path: #{req.path}" if %i[throttle blocklist].include?(req.env['rack.attack.match_type'])
end
