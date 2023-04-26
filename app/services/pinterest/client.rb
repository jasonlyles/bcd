# frozen_string_literal: true

# TODO: Deleting pins via retiring/deleting a product should update the related
# pins in Pinterest to point to somewhere in BCD.

module Pinterest
  class Client
    def initialize(options = {})
      @product_id = options[:product_id]
      @product = Product.find(@product_id) if @product_id.present?
      @board = options[:board]
    end

    # Pinterest::Client.new(product_id: 15, board: PinterestBoard.find_by_topic('base_product')).create_pin
    # rubocop:disable Metrics/MethodLength
    def create_pin
      success = false

      link = @product.etsy_listing_url
      title = "Custom Lego Instructions - #{@product.name}"
      description = @product.description.truncate(500)
      image = @product.images.first # first, as ranked by position

      response = Pinterest::Api::Pin.new(
        image:,
        title:,
        description:,
        link:,
        board_id: @board.pinterest_native_id
      ).create

      PinterestPin.create!(
        pinterest_native_id: response['id'],
        pinterest_board_id: @board.id,
        product_id: @product_id,
        link:,
        title:,
        description:,
        image_id: image.id
      )
      success = true
    rescue StandardError => e
      message = "Pinterest::Client#create_pin: #{e.message}"
      Rails.logger.error(message)
      ExceptionNotifier.notify_exception(e, data: { message: })
    ensure
      success
    end
    # rubocop:enable Metrics/MethodLength

    def create_board(name, description, topic)
      success = false
      response = Pinterest::Api::Board.new(
        name:,
        description:
      ).create

      PinterestBoard.create!(
        topic:,
        pinterest_native_id: response['id']
      )
      success = true
    rescue StandardError => e
      message = "Pinterest::Client#create_board: #{e.message}"
      Rails.logger.error(message)
      ExceptionNotifier.notify_exception(e, data: { message: })
    ensure
      success
    end
  end
end
