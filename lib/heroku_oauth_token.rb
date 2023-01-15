# frozen_string_literal: true

# nocov on this since this is about to go away
# :nocov:
class HerokuOauthToken
  def self.retrieve_token
    uri = URI.parse('https://api.heroku.com/oauth/authorizations')
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(Rails.application.credentials.heroku.email, Rails.application.credentials.heroku.api_key)
    request.body = JSON.dump({
                               'scope' => [
                                 'global'
                               ]
                             })
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/vnd.heroku+json; version=3'

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    JSON.parse(response.body)['access_token']['token']
  end
end
# :nocov:
