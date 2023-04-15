# frozen_string_literal: true

module Etsy
  module Api
    class ListingFile < Base
      def initialize(options = {})
        @listing_id = options[:listing_id]
        @listing_file_id = options[:listing_file_id]
        @shop_id = Rails.application.credentials.etsy.shop_id
      end

      # For uploading instructions PDFs:
      # Etsy API name: uploadListingFile
      # Just call the API and return the response

      # SAMPLE RESPONSE: "{\"listing_file_id\":1151390140461,\"listing_id\":1437428135,\"rank\":1,\"filename\":\"just_testing.pdf\",\"filesize\":\"11.16 KB\",\"size_bytes\":11427,\"filetype\":\"application\\/pdf\",\"create_timestamp\":1678713911,\"created_timestamp\":1678713911}\n"
      def add_pdf
        # Because of Etsy's file size limitation, we can't upload our instructions
        # to Etsy for hosting. So, we have to have a generic "Welcome to" type of PDF
        # that is the same for all products.
        t = Tempfile.new
        t.write(File.open("#{Rails.root}/app/assets/etsy/etsy_bcd_intro.pdf").read)
        t.close

        file = t.path

        # Changing filename to this since all uploads are the same file.
        filename = 'etsy_bcd_intro.pdf'
        payload = {
          file: Faraday::UploadIO.new(file, 'application/pdf'),
          name: filename
        }
        response_body = api_post_file("shops/#{@shop_id}/listings/#{@listing_id}/files", payload)

        # clean up the Tempfile
        t.unlink

        response_body
      end

      # If a new PDF needs to be uploaded, we have to upload a new one, but must delete
      # the old one first: deleteListingFile
      def delete_pdf
        api_delete("/shops/#{@shop_id}/listings/#{@listing_id}/files/#{@listing_file_id}")
      end
    end
  end
end
