# frozen_string_literal: true

class Rebrickable
  REBRICKABLE_URL = 'https://rebrickable.com'

  # For GETs
  def self.request(path)
    uri = URI.parse("#{REBRICKABLE_URL}/api/v3/#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new(uri.request_uri)
    req['Authorization'] = "key #{ENV['REBRICKABLE_API_KEY']}"
    req['Accept'] = 'application/json'
    http.request(req)
  end

  def self.post_request(path, body)
    uri = URI.parse("#{REBRICKABLE_URL}/api/v3/#{path}")
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/x-www-form-urlencoded'
    request['Accept'] = 'application/json'
    request['Authorization'] = "key #{ENV['REBRICKABLE_API_KEY']}"
    request.set_form_data(
      body
    )

    req_options = {
      use_ssl: uri.scheme == 'https'
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    response
  end

  def self.get_element_combo(part_id:, color_id:)
    response = request("lego/parts/#{part_id}/colors/#{color_id}/")
    JSON.parse(response.body)
  end

  # I probably won't actually use this call, but I might think of a use case
  def self.get_element_combo_sets(part_id, color_id)
    response = request("lego/parts/#{part_id}/colors/#{color_id}/sets/")
    JSON.parse(response.body)
  end

  # From this, I can get part info, such as BrickOwl ID, which might be useful for sending to a BrickOwl wishlist.
  def self.get_part(part_id)
    response = request("lego/parts/#{part_id}/")
    JSON.parse(response.body)
  end

  def self.get_color(color_id)
    response = request("lego/colors/#{color_id}/")
    JSON.parse(response.body)
  end

  # I think I only want to use this once per user, then I can save the token I get back for them.
  # Will need to allow user to re-fetch their token in case it has expired or been invalidated.
  # This should return nil if there's a problem
  def self.get_user_token(username, password)
    body = {
      'username' => username,
      'password' => password
    }
    response = post_request('users/_token/', body)
    JSON.parse(response.body)['user_token']
  end

  def self.get_all_users_parts(token)
    response = request("users/#{token}/allparts/")
    JSON.parse(response.body)
  end
end
