require 'spec_helper'

describe Subcategory do
  before do
    @product_type = FactoryGirl.create(:product_type)
  end
  describe "find_live_subcategories" do
    it "should only find subcategories that are ready for the public" do
      #First subcategory is ready for public, 2nd one is not, so there should only be 1 category
      @subcategories = [FactoryGirl.create(:subcategory),
                     FactoryGirl.create(:subcategory, :name => "Star Wars", :category_id => 1, :code => "SW", :ready_for_public => "f")
      ]
      @subcategories = Subcategory.find_live_subcategories
      @subcategories.should have(1).item
    end
  end

  it "should not delete products" do
    @category = FactoryGirl.create(:category)
    @subcategory = FactoryGirl.create(:subcategory)
    @product = FactoryGirl.create(:product)

    lambda { @subcategory.destroy }.should_not change(Product, :count)
  end

  it "should be valid with valid attributes" do
    subcat = FactoryGirl.create(:subcategory)
    subcat.should be_valid
  end

  it "should not be valid without a name" do
    subcat = Subcategory.new(:code => "WX")
    subcat.errors_on(:name).should == ["can't be blank"]
  end

  it "should not be valid without a code" do
    subcat = Subcategory.new(:name => "Awesome")
    subcat.errors_on(:code).should == ["can't be blank"]
  end

  it "should not be valid if code is not unique" do
    subcat1 = FactoryGirl.create(:subcategory)
    subcat2 = Subcategory.new(:code => "CV")
    subcat2.errors_on(:code).should == ["has already been taken"]
  end

  describe "self.model_code" do
    it "should suggest a model code based on the subcategory code and the number of products belonging to that subcategory" do
      @subcategory = FactoryGirl.create(:subcategory)
      model_code = Subcategory.model_code(@subcategory.id)

      model_code.should == "#{@subcategory.code}001"
    end

    it "should suggest a model code of XX010 for the 10th product in a subcategory" do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      9.times do |i|
        FactoryGirl.create(:product, :product_code => "#{@subcategory.code}00#{i+1}", :name => "TEST#{i+1}")
      end
      model_code = Subcategory.model_code(@subcategory.id)

      model_code.should == "#{@subcategory.code}010"
    end

    it "should suggest a model code of XX100 for the 100th product in a subcategory" do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      99.times do |i|
        if i < 9
          FactoryGirl.create(:product, :product_code => "#{@subcategory.code}00#{i+1}", :name => "TEST#{i+1}")
        else
          FactoryGirl.create(:product, :product_code => "#{@subcategory.code}0#{i+1}", :name => "TEST#{i+1}")
        end
      end
      model_code = Subcategory.model_code(@subcategory.id)

      model_code.should == "#{@subcategory.code}100"
    end
  end
end
