require 'spec_helper'

describe Category do
  describe "find_live_categories" do
    it "should only find categories that are ready for the public" do
      #First category is ready for public, 2nd one is not, so there should only be 1 category
      @categories = [FactoryGirl.create(:category),
                 FactoryGirl.create(:category, :name => "Star Wars", :ready_for_public => "f")
      ]
      @categories = Category.find_live_categories
      @categories.should have(1).item
    end
  end

  it "should delete any subcategories" do
    @category = FactoryGirl.create(:category_with_subcategories)

    lambda{@category.destroy}.should change(Subcategory, :count).from(1).to(0)
  end

  it "should not be valid without a name" do
    @category = Category.new(:ready_for_public => 't')
    @category.errors_on(:name).should == ["can't be blank"]
  end

  it "should not be valid without a description" do
    @category = Category.new(:ready_for_public => 't')
    @category.errors_on(:description).should include("can't be blank")
  end

  it "should not be valid if name is not unique" do
    @cat1 = FactoryGirl.create(:category)
    @cat2 = Category.new(:name => "City")
    @cat2.errors_on(:name).should == ["has already been taken"]
  end

  it "should not be valid with a description of invalid length" do
    @category = Category.new(:description => "Neat!")
    @category.errors_on(:description).should == ["is too short (minimum is 100 characters)"]
  end

  it "should be valid with valid attributes" do
    @category = FactoryGirl.create(:category)
    @category.should be_valid
  end
end
