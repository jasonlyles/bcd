# Rails + Cloudflare + Heroku Migration & Security Checklist

A step-by-step operational checklist for migrating a Ruby on Rails application hosted on Heroku behind Cloudflare's edge proxy, ensuring end-to-end SSL, origin shielding, and real client IP resolution.

---

## 1. Cloudflare & DNS Setup

* [ ] **Add Site to Cloudflare**
* Add your root domain (e.g., `example.com`) in the Cloudflare Dashboard to scan existing DNS records.


* [ ] **Update Nameservers at Registrar**
* Log in to your domain registrar (DNSimple, Namecheap, GoDaddy, etc.) and replace your current nameservers with the 2 nameservers assigned by Cloudflare.


* [ ] **Configure CNAME Flattening & Records**
* Add a `CNAME` for the root domain (`@` / `example.com`) pointing to your Heroku app target (`your-app-name.herokuapp.com` or custom Heroku target).
* Add a `CNAME` for `www` pointing to `example.com` or your Heroku DNS target.


* [ ] **Enable Proxy Status**
* Toggle the **Proxy Status** to **Orange Cloud (Proxied)** for both the root and `www` records.



---

## 2. SSL/TLS & Edge Optimization

* [ ] **Set SSL/TLS Encryption Mode to Full (Strict)**
* Navigate to **SSL/TLS** → **Overview** and set the encryption mode to **Full (Strict)**. This enforces valid Let's Encrypt certificates between Cloudflare and Heroku.


* [ ] **Enable Always Use HTTPS**
* Navigate to **SSL/TLS** → **Edge Certificates** and toggle **Always Use HTTPS** to **ON**.


* [ ] **Enable Automatic HTTPS Rewrites**
* Navigate to **SSL/TLS** → **Edge Certificates** and toggle **Automatic HTTPS Rewrites** to **ON** to prevent mixed-content asset warnings.


* [ ] **Enable Bot Mitigation**
* Navigate to **Security** → **Bots** and toggle **Bot Fight Mode** to **ON**.



---

## 3. Rails Gem & Application Configuration

* [ ] **Add `cloudflare-rails` Gem**
* Add the gem to your `Gemfile` to handle proxy IP unwrapping and restore true client IPs in `request.remote_ip`:
```ruby
gem 'cloudflare-rails'

```




* [ ] **Configure `config.hosts` (`config/environments/production.rb`)**
* Restrict accepted Host headers to prevent Host Header Injection attacks and direct-to-origin scanning:
```ruby
config.hosts = [
  "example.com",
  "www.example.com"
]

```




* [ ] **Keep `config.force_ssl = true` (`config/environments/production.rb`)**
* Ensure session cookies retain the `Secure` flag and HTTP Strict Transport Security (HSTS) headers remain enabled.



---

## 4. Origin Shielding via `Rack::Attack`

* [ ] **Install `rack-attack` Gem**
* Add the gem to your `Gemfile` if it is not already present:
```ruby
gem 'rack-attack'

```




* [ ] **Configure Direct-to-Origin Blocklist (`config/initializers/rack_attack.rb`)**
* Drop any request reaching Heroku that did not pass through Cloudflare's edge proxy:
```ruby
# frozen_string_literal: true

class Rack::Attack
  ### 1. Safelists ###
  safelist('allow-localhost') do |req|
    ['127.0.0.1', '::1'].include?(req.ip)
  end

  ### 2. Blocklists ###
  blocklist('Cloudflare WAF bypass') do |req|
    # Skip in development/test so local requests are not blocked
    next false unless Rails.env.production?

    # Reject requests missing Cloudflare's edge-injected header
    req.env['HTTP_CF_RAY'].blank?
  end
end

```

---

## 5. Verification & Testing

* [ ] **Verify Edge Header Termination (`curl`)**
* Run a header check from your terminal:
```bash
curl -I https://example.com

```


* Confirm that both `server: cloudflare` and `cf-ray: <ID>` appear in the HTTP response headers.


* [ ] **Verify Real IP Resolution in Logs**
* Monitor your Heroku logs (`heroku logs --tail`) while visiting the app. Confirm that logs display actual visitor IPs instead of Cloudflare proxy IPs.


* [ ] **Verify Direct IP Shielding**
* Execute a `curl` request directly against your underlying Heroku domain (`[https://your-app-name.herokuapp.com](https://your-app-name.herokuapp.com)`). Confirm it receives a `403 Forbidden` from `Rack::Attack` or is rejected by `config.hosts`.
