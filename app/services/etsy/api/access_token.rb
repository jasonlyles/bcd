# frozen_string_literal: true

module Etsy
  module Api
    class AccessToken < Base
      # Takes code we got back from Etsy and the code_verifier we stored in session
      # for the PKCE challenge and sends them back to Etsy to verify and get our access
      # token and refresh token. We then store those 2 tokens so we can use them for
      # our API calls.
      # rubocop:disable Metrics/AbcSize
      def self.get(code, etsy_code_verifier)
        uri = URI.parse("#{ETSY_API_URL}/public/oauth/token")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = {
          grant_type: 'authorization_code',
          client_id: Rails.application.credentials.etsy.api_key,
          redirect_uri: "#{Rails.application.config.web_host}/etsy/callback",
          code:,
          code_verifier: etsy_code_verifier
        }.to_json

        request['Content-Type'] = 'application/json'

        response = http.request(request)
        raise EtsyAccessTokenRetrievalError, "Got a #{response.code} from Etsy. Response: #{response.body}" unless response.code == '200'

        body = JSON.parse(response.body)
        { access_token: body['access_token'], refresh_token: body['refresh_token'], expires_at: Time.now + body['expires_in'] }
      end
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      def self.refresh
        uri = URI.parse("#{ETSY_API_URL}/public/oauth/token")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = {
          grant_type: 'refresh_token',
          client_id: Rails.application.credentials.etsy.api_key,
          refresh_token: BackendOauthToken.etsy.first.refresh_token
        }.to_json

        request['Content-Type'] = 'application/json'

        response = http.request(request)
        raise EtsyRefreshAccessTokenRetrievalError, "Got a #{response.code} from Etsy. Response: #{response.body}" unless response.code == '200'

        body = JSON.parse(response.body)
        store(body['access_token'], body['refresh_token'], Time.now + body['expires_in'])
      end
      # rubocop:enable Metrics/AbcSize

      def self.store(access_token, refresh_token, expires_at)
        bot = BackendOauthToken.find_or_create_by(provider: :etsy)
        bot.update(access_token:, refresh_token:, expires_at:)
      end
    end
  end
end
