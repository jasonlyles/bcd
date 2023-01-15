# frozen_string_literal: true

# Temporarily disable rubocop and simplecov for this file since it's still very much a WIP
# rubocop:disable all
# :nocov:
# TODO: This is a work in progress that I'll get back to once the backend is
# functional and the new parts list v1 is deployed.
class BrickOwl
  BRICKOWL_URL = 'https://api.brickowl.com'

  # For GETs
  # Pass in args as: '&thing=1&other_thing=2'
  def self.get_request(path, args = nil)
    key = Rails.application.credentials.brickowl.api_key
    uri = URI.parse("#{BRICKOWL_URL}/v1/#{path}?key=#{key}#{args}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new(uri.request_uri)
    req['Accept'] = 'application/json'
    http.request(req)
  end

  # Pass in args as: '&thing=1&other_thing=2'
  def self.post_request(path, body)
    key = Rails.application.credentials.brickowl.api_key
    uri = URI.parse("#{BRICKOWL_URL}/v1/#{path}")
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request['Accept'] = 'application/json'
    request.set_form_data(
      body.merge('key' => key)
    )
    req_options = {
      use_ssl: uri.scheme == 'https'
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    response
  end

  # items - JSON Array of in the format:
  # {"items":[{"design_id":"3034","color_id":21,"qty":"1"},{"design_id":"3004","color_id":23,"qty":"2"}]}
  # condition - A minimum condition code for the items:
  # one of (new, useda, usedg, usedn). These represent new, used acceptable, used good, and used like new.
  # country - 2 digit country code for shipping destination
  # TODO: This is not working at all, I just got the initial set up in place
  def self.get_price_list_via_cart(parts_colors)
    response = post_request('catalog/cart_basic', parts_colors)
    JSON.parse(response.body)
  end

  # Not sure I need this, but it works to prove I can hit the API
  def self.retrieve_wishlists
    response = get_request('wishlist/lists')
    JSON.parse(response.body)
  end

  # TODO: I think I need to extract some of this into a Wishlist class.
  # May want to save wishlist IDs to the database, and tie them to a user and a parts_list or product.
  # That way if a user pulls up their parts list again, I'm able to sync the parts list
  # with the users BrickOwl wishlist.

  # Creating a wishlist requires 3 different calls. One to create the list, one
  # to create lots for the list, and one to update the lots for the list.
  def self.populate_wishlist(name, parts_hash = nil)
    wishlist_id = create_wishlist(name, parts_hash)
    parts_hash.each do |part|
      # TODO: Get this sorted:
      lot_id = create_lot(wishlist_id, part['brickowl_id'], part['color_id'])
      update_lot(wishlist_id, lot_id, part['quantity'], part['condition'])
    end
  end

  def self.create_lot(wishlist_id, _boid, _color_id)
    # TODO: Determine the correct boid and color_id to use
    body = { 'wishlist_id' => wishlist_id, 'boid' => '400864', 'color_id' => '23' }
    response = post_request('wishlist/create_lot', body)
    json = JSON.parse(response.body)
    # json['error']['status']
    if json.keys.include?('error')
      # TODO: Track errors and bubble them up to the user.
      # json['error']['status']
    end
    if json.keys.include?('status') && json['status'].casecmp('success').zero?
      # TODO: Do something with this: lot_id = json['lot_id']
    else
      # TODO: bubble up some error to the user
    end
  end

  def self.update_lot(wishlist_id, lot_id, _quantity, _condition)
    # TODO: Don't need to make this last call if the desired qty is 1, since
    # that's what it's set to by the previous call.

    # # minimum_condition (Optional) - A Brick Owl condition ID, for example 'new' or 'useda' or blank. options: (new, useda, usedg, usedn)
    body = { 'wishlist_id' => wishlist_id, 'lot_id' => lot_id, 'minimum_quantity' => 5 }
    response = post_request('wishlist/update', body)
    json = JSON.parse(response.body)

    if json.keys.include?('error')
      # TODO: Track errors and bubble them up to the user.
      # json['error']['status']
    end
    if json.keys.include?('status') && json['status'].casecmp('success').zero?
      # lot_id = json['lot_id']
    else
      # TODO: bubble up some error to the user
    end
  end

  # TODO: What do I do if a wishlist is partially completed? Just let the user
  # know? Give them the option to delete the wish list?
  def self.create_wishlist(name, _parts_hash = nil)
    body = { 'name' => name }
    response = post_request('wishlist/create_list', body)
    json = JSON.parse(response.body)
    if json.keys.include?('error')
      # TODO: Handle user trying to create a wishlist with a name that already exists
      # TODO: bubble up some error to the user
    end
    if json.keys.include?('status') && json['status'].casecmp('success').zero?
      wishlist_id = json['wishlist_id']
    else
      # TODO: bubble up some error to the user
    end
    wishlist_id
  end
end
# rubocop:enable all
# :nocov:
