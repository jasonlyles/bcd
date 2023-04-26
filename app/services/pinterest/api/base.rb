# frozen_string_literal: true

module Pinterest
  module Api
    class Base
      class PinterestAccessTokenRetrievalError < StandardError; end
      class PinterestRefreshAccessTokenRetrievalError < StandardError; end
      class PinterestApiError < StandardError; end

      PINTEREST_API_URL = Rails.application.config.pinterest_api_url

      private

      # For API GETs
      def api_get(path)
        uri = URI.parse("#{PINTEREST_API_URL}/#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)

        request['Authorization'] = "Bearer #{BackendOauthToken.pinterest.first.access_token}"
        request['Content-Type'] = 'application/json'

        response = http.request(request)
        raise PinterestApiError, "Got a #{response.code} from Pinterest in api_get for #{path}. Response: #{response.body}" unless response.code == '200'

        JSON.parse(response.body)
      end

      # For API POSTs
      def api_post(path, request_body)
        uri = URI.parse("#{PINTEREST_API_URL}/#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)

        request['Authorization'] = "Bearer #{BackendOauthToken.pinterest.first.access_token}"
        request['Content-Type'] = 'application/json'

        response = http.request(request, request_body)
        raise PinterestApiError, "Got a #{response.code} from Pinterest in api_post for #{path}. Response: #{response.body}" unless response.code == '201'

        JSON.parse(response.body)
      end
    end
  end
end
