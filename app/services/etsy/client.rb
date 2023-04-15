# frozen_string_literal: true

module Etsy
  class Client
    def initialize(options = {})
      @product_id = options[:product_id]
      @product = Product.find(@product_id)
      @listing_id = @product.etsy_listing_id
      @shop_id = Rails.application.credentials.etsy.shop_id
    end

    # Flow to create a listing in Etsy:
    # 1. After a product is live in BCD, we can publish it to Etsy. (Add a publish to etsy button, and another for updating etsy.)
    # 2. Call Etsy::Api::Listing.new.create_draft_listing to create the base listing.
    #   a. Save the listing_id on the product model
    #   b. update product model etsy_listing_state
    # 3. Call Etsy::Api::Listing.new.add_sku to add a sku to the product that we can use to identify sales.
    #   a. update product model etsy_listing_state
    # 4. Call Etsy::Api::ListingFile.new to add the instructions to the Etsy listing.
    #   a. update product model etsy_listing_state
    # 5. Call Etsy::Api::ListingImage.new.add on each product image. to add the products images
    #    to the Etsy listing.
    #   a. update product model etsy_listing_state
    #   b. update image model etsy_listing_image_id
    # 6. Call Etsy::Api::Listing.new.activate to set the Etsy listings state to active.
    #   a. update product model etsy_listing_state
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def create_listing
      success = false
      # Create draft listing and update product with id and state
      listing = Etsy::Api::Listing.new
      response = listing.create_draft(@product.etsy_wrapped_title, @product.etsy_wrapped_description, @product.price.to_f, @product.tag_list[0..12].join(', '))

      @listing_id = response['listing_id']
      url = response['url']
      @product.update(
        etsy_listing_id: @listing_id,
        etsy_listing_state: 'draft_created',
        etsy_listing_url: url
      )

      # Add sku to the listing and update state
      listing.add_sku(@product.product_code, @product.price.to_f)

      @product.update(
        etsy_listing_state: 'sku_added',
        etsy_updated_at: Time.now
      )

      # Add pdf and update product state
      response = Etsy::Api::ListingFile.new(listing_id: @listing_id).add_pdf

      # Store the listing_file_id for later access, should I need to delete the listing file.
      @product.update(
        etsy_listing_file_id: response['listing_file_id'],
        etsy_listing_state: 'pdf_added'
      )

      # Add images to the listing and update product state
      @product.images.order(position: :asc).limit(10).each { |image| add_image(image) }
      @product.update(etsy_listing_state: 'images_added')

      # Activate the listing and update product state and etsy timestamps
      response = listing.activate

      time = Time.now
      @product.update(
        etsy_listing_state: 'published',
        etsy_created_at: time,
        etsy_updated_at: time,
        etsy_listing_url: response['url']
      )
      success = true
    rescue StandardError => e
      message = "Etsy::Client#create_listing Product #{@product.id}: #{e.message}"
      Rails.logger.error(message)
      ExceptionNotifier.notify_exception(e, data: { message: })
    ensure
      success
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize
    def update_listing
      success = false
      # First we update product attributes
      listing = Etsy::Api::Listing.new(listing_id: @product.etsy_listing_id)
      response = listing.update(@product.etsy_wrapped_title, @product.etsy_wrapped_description, @product.tag_list[0..12].join(', '))

      # Can't update price with the above call, have to make a call to Etsy's updateListingInventory
      listing.update_property(@product.product_code, @product.price.to_f)

      if should_update_images?(@product)
        # The only clean way I've found to address changes in images is to wipe them all out...
        @product.images.where('etsy_listing_image_id IS NOT NULL').each { |image| delete_image(image.etsy_listing_image_id) }
        # ...and then add them all back.
        @product.images.where('position <= 10').each { |image| add_image(image) }
      end

      @product.update(etsy_updated_at: Time.now, etsy_listing_url: response['url'])
      success = true
    rescue StandardError => e
      message = "Etsy::Client#update_listing Product #{@product.id}: #{e.message}"
      Rails.logger.error(message)
      ExceptionNotifier.notify_exception(e, data: { message: })
    ensure
      success
    end
    # rubocop:enable Metrics/AbcSize

    def delete_listing
      success = false
      Etsy::Api::Listing.new(listing_id: @product.etsy_listing_id).delete

      # remove listing info from product...
      @product.update(
        etsy_listing_id: nil,
        etsy_listing_file_id: nil,
        etsy_listing_state: nil,
        etsy_listing_url: nil,
        etsy_created_at: nil,
        etsy_updated_at: nil
      )
      # ...and related images.
      @product.images.each { |image| image.update(etsy_listing_image_id: nil) }
      success = true
    rescue StandardError => e
      message = "Etsy::Client#delete_listing Product #{@product.id}: #{e.message}"
      Rails.logger.error(message)
      ExceptionNotifier.notify_exception(e, data: { message: })
    ensure
      success
    end

    def delete_image(listing_image_id)
      Etsy::Api::ListingImage.new(listing_image_id:, listing_id: @listing_id).delete

      image = Image.where(etsy_listing_image_id: listing_image_id)
      image.update(etsy_listing_image_id: nil) if image.exists?
    end

    def replace_pdf
      # Store old listing_file_id for later use when deleting.
      old_etsy_listing_file_id = @product.etsy_listing_file_id

      # Add new file before removing the existing file.
      response = Etsy::Api::ListingFile.new(listing_id: @listing_id).add_pdf

      # If we added a new file...
      return unless response['listing_file_id'].present?

      # ...update the database...
      @product.update(
        etsy_listing_file_id: response['listing_file_id'],
        etsy_updated_at: Time.now
      )
      # ...and then delete the old one from Etsy.
      Etsy::Api::ListingFile.new(listing_id: @listing_id, listing_file_id: old_etsy_listing_file_id).delete_pdf
    end

    private

    def should_update_images?(product)
      product.images.where('etsy_listing_image_id IS NOT NULL').map(&:updated_at).select { |date| date > product.updated_at }.present?
    end

    def add_image(image)
      response = Etsy::Api::ListingImage.new(image_file: image.url.file.file, image_filename: image.url.file.filename, listing_id: @listing_id, image_rank: image.position).add

      # Store the listing_image_id for later, in case we want to destroy or otherwise reference this image.
      image.update(etsy_listing_image_id: response['listing_image_id'])
    end
  end
end
