# frozen_string_literal: true

module Etsy
  module Api
    class ListingImage < Base
      def initialize(options = {})
        @listing_id = options[:listing_id]
        @listing_image_id = options[:listing_image_id]
        @image_file = options[:image_file]
        @image_filename = options[:image_filename]
        @image_rank = options[:image_rank]
        @shop_id = Rails.application.credentials.etsy.shop_id
      end

      # For adding images to the product listing:
      # Etsy API name: uploadListingImage
      # Just call the API and return the response
      #
      # SAMPLE RESPONSE: "{\"listing_id\":1437428135,\"listing_image_id\":4720544900,\"hex_code\":null,\"red\":null,\"green\":null,\"blue\":null,\"hue\":null,\"saturation\":null,\"brightness\":null,\"is_black_and_white\":null,\"creation_tsz\":1678797166,\"created_timestamp\":1678797166,\"rank\":1,\"url_75x75\":\"https:\\/\\/i.etsystatic.com\\/41602694\\/r\\/il\\/943e08\\/4720544900\\/il_75x75.4720544900_sqzg.jpg\",\"url_170x135\":\"https:\\/\\/i.etsystatic.com\\/41602694\\/r\\/il\\/943e08\\/4720544900\\/il_170x135.4720544900_sqzg.jpg\",\"url_570xN\":\"https:\\/\\/i.etsystatic.com\\/41602694\\/r\\/il\\/943e08\\/4720544900\\/il_570xN.4720544900_sqzg.jpg\",\"url_fullxfull\":\"https:\\/\\/i.etsystatic.com\\/41602694\\/r\\/il\\/943e08\\/4720544900\\/il_fullxfull.4720544900_sqzg.jpg\",\"full_height\":null,\"full_width\":null,\"alt_text\":\"\"}\n"
      def add
        t = Tempfile.new
        t.write(File.open(@image_file).read)
        t.close

        file = t.path
        mime_type = MIME::Types.type_for(@image_filename).first.content_type
        payload = {
          image: Faraday::UploadIO.new(file, mime_type),
          rank: @image_rank
        }
        response_body = api_post_file("shops/#{@shop_id}/listings/#{@listing_id}/images", payload)

        # clean up the Tempfile
        t.unlink

        response_body
      end

      # If I have to delete an image:
      # deleteListingImage
      def delete
        api_delete("shops/#{@shop_id}/listings/#{@listing_id}/images/#{@listing_image_id}")
      end
    end
  end
end
