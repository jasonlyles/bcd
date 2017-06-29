class HerokuOauthToken
  def self.get_token
    uri = URI.parse("https://api.heroku.com/oauth/authorizations")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(ENV['BCD_HEROKU_EMAIL'], ENV['HEROKU_API_KEY'])
    request.body = JSON.dump({
                                 "scope" => [
                                     "global"
                                 ]
                             })
    request['Content-Type'] = "application/json"
    request['Accept'] = "application/vnd.heroku+json; version=3"

    req_options = {
        use_ssl: uri.scheme == "https"
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    JSON.parse(response.body)['access_token']['token']
  end
end