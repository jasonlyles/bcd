# frozen_string_literal: true

# Not necessary for what we're doing, just a way to find taxonomies and their IDs
# def self.get_taxonomy_nodes
#   response_body = api_get('seller-taxonomy/nodes')
# end

# If I ever get bored, I could work on pulling back reviews from Etsy using getReviewsByShop

module Etsy
  module Api
    class Base
      class EtsyAccessTokenRetrievalError < StandardError; end
      class EtsyRefreshAccessTokenRetrievalError < StandardError; end
      class EtsyApiError < StandardError; end

      ETSY_API_URL = 'https://api.etsy.com/v3'

      private

      # For API GETs
      def api_get(path)
        uri = URI.parse("#{ETSY_API_URL}/application/#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)

        request['x-api-key'] = Rails.application.credentials.etsy.api_key
        request['Authorization'] = "Bearer #{BackendOauthToken.etsy.first.access_token}"

        response = http.request(request)

        raise EtsyApiError, "Got a #{response.code} from Etsy in api_get for #{path}. Response: #{response.body}" unless response.code == '200'

        JSON.parse(response.body)
      end

      # For API POSTs
      def api_post(path, request_body)
        uri = URI.parse("#{ETSY_API_URL}/application/#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)

        request['x-api-key'] = Rails.application.credentials.etsy.api_key
        request['Authorization'] = "Bearer #{BackendOauthToken.etsy.first.access_token}"
        request['Content-Type'] = 'application/x-www-form-urlencoded'

        encoded_form = URI.encode_www_form(request_body)

        response = http.request(request, encoded_form)

        raise EtsyApiError, "Got a #{response.code} from Etsy in api_post for #{path}. Response: #{response.body}" unless response.code == '201'

        JSON.parse(response.body)
      end

      # For API POSTs where we are uploading a file (PDFs, Images)
      def api_post_file(path, payload)
        conn = Faraday.new(ETSY_API_URL) do |f|
          f.request :multipart
          f.request :url_encoded
          f.headers['x-api-key'] = Rails.application.credentials.etsy.api_key
          f.headers['Authorization'] = "Bearer #{BackendOauthToken.etsy.first.access_token}"
          f.adapter :net_http
        end

        response = conn.post("#{ETSY_API_URL}/application/#{path}", payload)

        raise EtsyApiError, "Got a #{response.status} from Etsy in api_post_file for #{path}. Response: #{response.body}" unless response.status == '201'

        JSON.parse(response.body)
      end

      # For API PUTs
      def api_put(path, request_body)
        uri = URI.parse("#{ETSY_API_URL}/application/#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Put.new(uri.request_uri)

        request['x-api-key'] = Rails.application.credentials.etsy.api_key
        request['Authorization'] = "Bearer #{BackendOauthToken.etsy.first.access_token}"
        request['Content-Type'] = 'application/json'

        request.body = request_body

        response = http.request(request)

        raise EtsyApiError, "Got a #{response.code} from Etsy in api_put for #{path}. Response: #{response.body}" unless response.code == '200'

        JSON.parse(response.body)
      end

      def api_delete(path)
        uri = URI.parse("#{ETSY_API_URL}/application/#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Delete.new(uri.request_uri)

        request['x-api-key'] = Rails.application.credentials.etsy.api_key
        request['Authorization'] = "Bearer #{BackendOauthToken.etsy.first.access_token}"

        response = http.request(request)

        raise EtsyApiError, "Got a #{response.code} from Etsy in api_delete for #{path}." unless response.code == '204'

        true
      end
    end
  end
end
