# frozen_string_literal: true

module Etsy
  module Api
    class Listing < Base
      def initialize(options = {})
        @listing_id = options[:listing_id]
        @shop_id = Rails.application.credentials.etsy.shop_id
      end

      # SAMPLE RESPONSE:
      # {"listing_id"=>1425050460,
      #  "user_id"=>757471822,
      #  "shop_id"=>41602694,
      #  "title"=>"Custom Lego instructions: Colonial Revival House",
      #  "description"=>
      #   "One of our best sellers, the Colonial Revival house modeled after a real house in the Fan in Richmond, VA. This model is modular and features 2 furnished floors, a crawlspace and a porch on front and back. This model will go great in any row house neighborhood in your modular city. Building sits on a 16x32 baseplate.",
      #  "state"=>"draft",
      #  "creation_timestamp"=>1678885745,
      #  "created_timestamp"=>1678885745,
      #  "ending_timestamp"=>1689426545,
      #  "original_creation_timestamp"=>1678885745,
      #  "last_modified_timestamp"=>1678885746,
      #  "updated_timestamp"=>1678885746,
      #  "state_timestamp"=>1678885745,
      #  "quantity"=>999,
      #  "shop_section_id"=>nil,
      #  "featured_rank"=>-1,
      #  "url"=>"https://www.etsy.com/listing/1425050460/custom-lego-instructions-colonial",
      #  "num_favorers"=>0,
      #  "non_taxable"=>false,
      #  "is_taxable"=>true,
      #  "is_customizable"=>false,
      #  "is_personalizable"=>false,
      #  "personalization_is_required"=>false,
      #  "personalization_char_count_max"=>nil,
      #  "personalization_instructions"=>nil,
      #  "listing_type"=>"download",
      #  "tags"=>[],
      #  "materials"=>[],
      #  "shipping_profile_id"=>nil,
      #  "return_policy_id"=>1,
      #  "processing_min"=>nil,
      #  "processing_max"=>nil,
      #  "who_made"=>"i_did",
      #  "when_made"=>"2010_2019",
      #  "is_supply"=>false,
      #  "item_weight"=>nil,
      #  "item_weight_unit"=>nil,
      #  "item_length"=>nil,
      #  "item_width"=>nil,
      #  "item_height"=>nil,
      #  "item_dimensions_unit"=>nil,
      #  "is_private"=>false,
      #  "style"=>[],
      #  "file_data"=>"",
      #  "has_variations"=>false,
      #  "should_auto_renew"=>true,
      #  "language"=>"en-US",
      #  "price"=>{"amount"=>1000, "divisor"=>100, "currency_code"=>"USD"},
      #  "taxonomy_id"=>1583,
      #  "production_partners"=>[],
      #  "skus"=>[],
      #  "views"=>0}
      # Etsy API name: createDraftListing
      def create_draft(product_name, product_description, product_price, tag_list)
        request_body = {
          quantity: 999,
          title: product_name,
          description: product_description,
          price: product_price,
          who_made: 'i_did',
          when_made: '2010_2019',
          taxonomy_id: 1583,
          should_auto_renew: true,
          type: 'download',
          tags: tag_list
        }

        response_body = api_post("shops/#{@shop_id}/listings", request_body)

        @listing_id = response_body['listing_id'] if response_body['listing_id'].present?
        response_body
      end

      # Etsy API name: updateListing
      # Call this method to update product attributes
      def update(product_name, product_description, tag_list)
        request_body = {
          title: product_name,
          description: product_description,
          tags: tag_list
        }.to_json

        api_put("/shops/#{@shop_id}/listings/#{@listing_id}", request_body)
      end

      # This is for adding skus and properties for variations of the product I believe,
      # but I just want to add a single sku to the product. Since I'm just doing the
      # one variation, I need to add the price a 2nd time.
      # Etsy API name: updateListingInventory
      # SAMPLE RESPONSE:
      #      {"products"=>
      #  [{"product_id"=>14192098817,
      #    "sku"=>"CB002",
      #    "is_deleted"=>false,
      #    "offerings"=>[{"offering_id"=>14501765500, "quantity"=>999, "is_enabled"=>true, "is_deleted"=>false, "price"=>{"amount"=>1000, "divisor"=>100, "currency_code"=>"USD"}}],
      #    "property_values"=>[]}],
      # "price_on_property"=>[],
      # "quantity_on_property"=>[],
      # "sku_on_property"=>[]}
      def update_property(product_code, product_price)
        request_body = {
          products: [
            sku: product_code,
            offerings: [
              {
                price: product_price,
                quantity: 999,
                is_enabled: true
              }
            ]
          ]
        }.to_json

        api_put("listings/#{@listing_id}/inventory", request_body)
      end
      alias add_sku update_property

      # Etsy API name: updateListing
      # Call this method to activate/publish a listing.
      # SAMPLE RESPONSE:
      # {"listing_id"=>1437428135,
      # "user_id"=>757471822,
      # "shop_id"=>41602694,
      # "title"=>"Custom Lego instructions: Sewer Truck",
      # "description"=>
      #  "It&#39;s a messy job, but someone has to do it. Keep the sewers clean and functioning properly in your city for the public&#39;s health and safety. Watch for alligators! Truck has a hose that can reach from the back of the truck to a manhole.",
      # "state"=>"active",
      # "creation_timestamp"=>1678851058,
      # "created_timestamp"=>1678851058,
      # "ending_timestamp"=>1689391858,
      # "original_creation_timestamp"=>1678666718,
      # "last_modified_timestamp"=>1678851058,
      # "updated_timestamp"=>1678851058,
      # "state_timestamp"=>1678836905,
      # "quantity"=>999,
      # "shop_section_id"=>nil,
      # "featured_rank"=>-1,
      # "url"=>"https://www.etsy.com/listing/1437428135/custom-lego-instructions-sewer-truck",
      # "num_favorers"=>0,
      # "non_taxable"=>false,
      # "is_taxable"=>true,
      # "is_customizable"=>false,
      # "is_personalizable"=>false,
      # "personalization_is_required"=>false,
      # "personalization_char_count_max"=>nil,
      # "personalization_instructions"=>nil,
      # "listing_type"=>"download",
      # "tags"=>[],
      # "materials"=>[],
      # "shipping_profile_id"=>nil,
      # "return_policy_id"=>1,
      # "processing_min"=>nil,
      # "processing_max"=>nil,
      # "who_made"=>"i_did",
      # "when_made"=>"2010_2019",
      # "is_supply"=>false,
      # "item_weight"=>nil,
      # "item_weight_unit"=>nil,
      # "item_length"=>nil,
      # "item_width"=>nil,
      # "item_height"=>nil,
      # "item_dimensions_unit"=>nil,
      # "is_private"=>false,
      # "style"=>[],
      # "file_data"=>"1 JPG, 1 PDF, 1 other file",
      # "has_variations"=>false,
      # "should_auto_renew"=>true,
      # "language"=>"en-US",
      # "price"=>{"amount"=>20, "divisor"=>100, "currency_code"=>"USD"},
      # "taxonomy_id"=>1583,
      # "production_partners"=>[],
      # "skus"=>[],
      # "views"=>0}
      def activate
        request_body = { state: 'active' }.to_json
        api_put("/shops/#{@shop_id}/listings/#{@listing_id}", request_body)
      end

      # deleteListing
      # Call this method to delete a listing
      def delete
        api_delete("/listings/#{@listing_id}")
      end
    end
  end
end
