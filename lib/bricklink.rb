# frozen_string_literal: true

class Bricklink
  BRICKLINK_URL = 'https://api.bricklink.com'

  # For GETs
  def self.request(path)
    uri = URI.parse("#{BRICKLINK_URL}/api/store/v1/#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    consumer = OAuth::Consumer.new(ENV['BRICKLINK_CONSUMER_KEY'], ENV['BRICKLINK_CONSUMER_SECRET'], site: BRICKLINK_URL)
    access_token_struct = OpenStruct.new(token: ENV['BRICKLINK_ACCESS_TOKEN'], secret: ENV['BRICKLINK_ACCESS_TOKEN_SECRET'])
    oauth_params = { consumer:, token: access_token_struct }
    oauth_helper = OAuth::Client::Helper.new(request, oauth_params.merge(request_uri: uri))
    request['Authorization'] = oauth_helper.header
    http.request(request)
  end

  # http://apidev.bricklink.com/redmine/projects/bricklink-api/wiki/CatalogMethod#Get-Item
  def self.get_part(part_id)
    response = request("items/part/#{part_id}")
    JSON.parse(response.body)
  end

  # http://apidev.bricklink.com/redmine/projects/bricklink-api/wiki/CatalogMethod#Get-Item-Image
  def self.get_element_image(part_id:, color_id:)
    response = request("items/part/#{part_id}/images/#{color_id}")
    JSON.parse(response.body)
  end

  # This can be used to return the Lego element ID, which can be good for
  # finding the piece in Lego.coms PAB store.
  # I guess what I would do would be to get everything back for an element, and the
  # records that have matching color IDs, I could also store the Lego element ID, and
  # display that in the parts list for any interested parties.
  # http://apidev.bricklink.com/redmine/projects/bricklink-api/wiki/ItemMappingMethod#Get-ElementID
  def self.get_element_id(part_id)
    response = request("item_mapping/part/#{part_id}")
    JSON.parse(response.body)
  end

  # http://apidev.bricklink.com/redmine/projects/bricklink-api/wiki/CatalogMethod#Get-Price-Guide
  # new_or_used: n or u
  # guide_type: sold or stock
  # country_code/region: Some country code (not sure which standard) plus asia, africa, north_america, south_america, middle_east, europe, eu, oceania
  # currency_code: some currency code (not sure which standard)
  # vat: N,Y,O (Norway)
  def self.get_price_guide(part_id:, color_id:, guide_type:, new_or_used:)
    response = request("items/part/#{part_id}/price?color_id=#{color_id}&guide_type=#{guide_type}&new_or_used=#{new_or_used}")
    JSON.parse(response.body)
  end

  # Can maybe use this to give users a dropdown to change colors for a particular part in the parts list if they want to.
  # Could maybe also use it to determine if a certain color is completely interchangeable with another color, in terms of part availability.
  # http://apidev.bricklink.com/redmine/projects/bricklink-api/wiki/CatalogMethod#Get-Known-Colors
  def self.get_known_colors(part_id)
    response = request("items/part/#{part_id}/colors")
    JSON.parse(response.body)
  end

  # http://apidev.bricklink.com/redmine/projects/bricklink-api/wiki/ColorMethod#Get-Color-List
  def self.retrieve_colors
    response = request('colors')
    JSON.parse(response.body)
  end

  # TODO: Superset and subset calls. These might be important to break out windows
  # into their separate pieces, for example, or to get a superset for something where
  # I use part of it, like the lever on a lever control stick thing.
end
