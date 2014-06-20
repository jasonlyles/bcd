module OAuth
  class RequestToken
    def build_authorize_url(base_url, params)
      uri = URI.parse(base_url.to_s)
      # TODO doesn't handle array values correctly
      uri.query = params.map { |k,v| [k, CGI.escape("#{v}")] * "=" } * "&"
      uri.to_s
    end
  end
end