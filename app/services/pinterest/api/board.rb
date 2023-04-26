# frozen_string_literal: true

module Pinterest
  module Api
    class Board < Base
      def initialize(options = {})
        @name = options[:name]
        @description = options[:description]
      end

      # SAMPLE RESPONSE:
      # "{\"items\":[{\"owner\":{\"username\":\"jasonl7711\"},\"created_at\":\"2023-04-24T12:40:08\",\"media\":{\"pin_thumbnail_urls\":[],\"image_cover_url\":null},\"pin_count\":0,\"follower_count\":0,\"description\":\"Just a test\",\"name\":\"Test board\",\"privacy\":\"PUBLIC\",\"id\":\"1056657200011327940\",\"collaborator_count\":0,\"board_pins_modified_at\":\"2023-04-24T12:40:08\"}],\"bookmark\":null}"
      def get
        api_get('boards')
      end

      # SAMPLE RESPONSE:
      # "{\"collaborator_count\":0,\"privacy\":\"PUBLIC\",\"board_pins_modified_at\":\"2023-04-24T12:40:08\",\"description\":\"Just a test\",\"created_at\":\"2023-04-24T12:40:08\",\"media\":{\"pin_thumbnail_urls\":[],\"image_cover_url\":null},\"name\":\"Test board\",\"id\":\"1056657200011327940\",\"pin_count\":0,\"follower_count\":0,\"owner\":{\"username\":\"jasonl7711\"}}"
      def create
        request_body = {
          name: @name,
          description: @description
        }.to_json

        api_post('boards', request_body)
      end
    end
  end
end
