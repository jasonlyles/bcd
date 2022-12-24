require 'spec_helper'

describe ProductType do
  describe "find_live_product_types" do
    it "should only find categories that are ready for the public" do
      #First product type is ready for public, 2nd one is not, so there should only be 1 product type
      @product_types = [FactoryBot.create(:product_type),
                     FactoryBot.create(:product_type, :name => "Crafts", :ready_for_public => "f")
      ]
      @product_types = ProductType.find_live_product_types

      expect(@product_types.size).to eq(1)
    end
  end
end
