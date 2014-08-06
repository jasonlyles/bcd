require 'spec_helper'



describe ApplicationHelper do
  describe "snippet" do
    it "should show only a snippet of a longer string" do
      helper.snippet("Brick City Depot will soon take over the custom lego instruction world!", :word_count => 5).should == "Brick City Depot will soon..."
    end
  end

  describe "featured_item" do
    it "should get a random product for featuring" do
      @product_type = FactoryGirl.create(:product_type)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @products = [FactoryGirl.create(:product, featured: 't'),
                    FactoryGirl.create(:product,
                                  :name => "Grader",
                                  :product_type_id => @product_type.id,
                                  :product_code => "WC002",
                                  :description => "Winter Village Grader... are you kidding? w00t! Plow your winter village to the ground and then flatten it out with this sweet grader.",
                                  :price => "5.00",
                                  :ready_for_public => "t",
                                  featured: 't'
                    )
      ]

      helper.featured_item.name.should match(/Colonial Revival House|Grader/)
    end
  end
end