# frozen_string_literal: true

require 'net/http'
require 'uri'

class SitemapsController < ApplicationController
  skip_before_action :verify_authenticity_token
  layout false

  def show
    response.headers['Content-Type'] = 'application/xml'
    response.headers['Content-Encoding'] = 'gzip'

    uri = URI.parse('https://brickcitydepot-assets.s3.amazonaws.com/sitemaps/sitemap.xml.gz')

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request_get(uri.path) do |res|
        res.read_body do |chunk|
          response.stream.write(chunk)
        end
      end
    end
  ensure
    response.stream.close
  end
end
