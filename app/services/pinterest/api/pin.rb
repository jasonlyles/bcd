# frozen_string_literal: true

module Pinterest
  module Api
    class Pin < Base
      def initialize(options = {})
        @link = options[:link]
        @title = options[:title]
        @description = options[:description]
        @image = options[:image]
        @board_id = options[:board_id]
      end

      # SAMPLE RESPONSE:
      # "{\"link\":\"https://brickcitydepot.com/\",\"id\":\"1056657131301696704\",\"title\":\"Test pin 2\",\"created_at\":\"2023-04-24T12:48:33\",\"board_id\":\"1056657200011327940\",\"parent_pin_id\":null,\"board_owner\":{\"username\":\"jasonl7711\"},\"dominant_color\":null,\"description\":\"Just a test, with my image\",\"media\":{\"media_type\":\"image\",\"images\":{\"150x150\":{\"width\":150,\"height\":150,\"url\":\"https://i.pinimg.com/150x150/36/df/5f/36df5fdf2db1aed775c0644f47b8add2.jpg\"},\"400x300\":{\"width\":400,\"height\":300,\"url\":\"https://i.pinimg.com/400x300/36/df/5f/36df5fdf2db1aed775c0644f47b8add2.jpg\"},\"600x\":{\"width\":600,\"height\":450,\"url\":\"https://i.pinimg.com/600x/36/df/5f/36df5fdf2db1aed775c0644f47b8add2.jpg\"},\"1200x\":{\"width\":700,\"height\":525,\"url\":\"https://i.pinimg.com/1200x/36/df/5f/36df5fdf2db1aed775c0644f47b8add2.jpg\"},\"originals\":{\"width\":700,\"height\":525,\"url\":\"https://i.pinimg.com/originals/36/df/5f/36df5fdf2db1aed775c0644f47b8add2.jpg\"}}},\"alt_text\":null,\"board_section_id\":null}"
      def create
        base64_image = File.open(@image.url.file.file, 'rb') do |file|
          Base64.strict_encode64(file.read)
        end

        # SAMPLE REQUEST BODY:
        # # {
        #   "link": "https://www.pinterest.com/",
        #   "title": "string",
        #   "description": "string",
        #   "dominant_color": "#6E7874",
        #   "alt_text": "string",
        #   "board_id": "string",
        #   "board_section_id": "string",
        #   "media_source": {
        #     "source_type": "image_base64",
        #     "content_type": "image/jpeg",
        #     "data": "string"
        #   },
        #   "parent_pin_id": "string"
        # }
        request_body = {
          link: @link,
          title: @title,
          description: @description,
          board_id: @board_id,
          media_source: {
            source_type: 'image_base64',
            content_type: 'image/jpeg',
            data: base64_image
          }
        }.to_json

        api_post('pins', request_body)
      end
    end
  end
end
