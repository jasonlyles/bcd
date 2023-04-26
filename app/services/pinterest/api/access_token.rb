# frozen_string_literal: true

module Pinterest
  module Api
    class AccessToken < Base
      def self.get(code)
        uri = URI.parse("#{PINTEREST_API_URL}/oauth/token")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        form_params = {
          grant_type: 'authorization_code',
          code:,
          redirect_uri: "#{Rails.application.config.web_host}/pinterest/callback"
        }
        encoded_form = URI.encode_www_form(form_params)
        headers = {
          content_type: 'application/x-www-form-urlencoded',
          authorization: "Basic #{setup_token}"
        }

        response = http.request_post(uri.request_uri, encoded_form, headers)
        raise PinterestAccessTokenRetrievalError, "Got a #{response.code} from Pinterest. Response: #{response.body}" unless response.code == '200'

        body = JSON.parse(response.body)
        { access_token: body['access_token'], refresh_token: body['refresh_token'], expires_at: Time.now + body['expires_in'] }
      end

      def self.refresh
        uri = URI.parse("#{PINTEREST_API_URL}/oauth/token")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        form_params = {
          grant_type: 'refresh_token',
          refresh_token: BackendOauthToken.pinterest.first.refresh_token,
          redirect_uri: "#{Rails.application.config.web_host}/pinterest/callback"
        }
        encoded_form = URI.encode_www_form(form_params)
        headers = {
          content_type: 'application/x-www-form-urlencoded',
          authorization: "Basic #{setup_token}"
        }

        response = http.request_post(uri.request_uri, encoded_form, headers)
        raise PinterestRefreshAccessTokenRetrievalError, "Got a #{response.code} from Pinterest. Response: #{response.body}" unless response.code == '200'

        body = JSON.parse(response.body)
        store(body['access_token'], Time.now + body['expires_in'])
      end

      def self.store(access_token, refresh_token, expires_at)
        bot = BackendOauthToken.find_or_create_by(provider: :pinterest)
        if refresh_token.present?
          bot.update(access_token:, refresh_token:, expires_at:)
        else
          bot.update(access_token:, expires_at:)
        end
      end

      def self.setup_token
        secret_key = Rails.application.credentials.pinterest.secret_key
        client_id = Rails.application.credentials.pinterest.app_id
        Base64.strict_encode64("#{client_id}:#{secret_key}")
      end
    end
  end
end
