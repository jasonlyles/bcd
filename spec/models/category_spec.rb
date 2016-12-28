require 'spec_helper'

describe Category do
  describe "find_live_categories" do
    it "should only find categories that are ready for the public" do
      #First category is ready for public, 2nd one is not, so there should only be 1 category
      @categories = [FactoryGirl.create(:category),
                 FactoryGirl.create(:category, :name => "Star Wars", :ready_for_public => "f")
      ]
      @categories = Category.find_live_categories
      expect(@categories.size).to eq(1)
    end
  end

  it "should delete any subcategories" do
    @category = FactoryGirl.create(:category_with_subcategories)

    expect(lambda{@category.destroy}).to change(Subcategory, :count).from(1).to(0)
  end

  it "should not be valid without a name" do
    @category = Category.create(:ready_for_public => 't')

    expect(@category.errors[:name]).to eq(["can't be blank"])
  end

  it "should not be valid without a description" do
    @category = Category.create(:ready_for_public => 't')

    expect(@category.errors[:description]).to include("can't be blank")
  end

  it "should not be valid if name is not unique" do
    @cat1 = FactoryGirl.create(:category)
    @cat2 = Category.create(:name => "City")

    expect(@cat2.errors[:name]).to eq(["has already been taken"])
  end

  it "should not be valid with a description of invalid length" do
    @category = Category.create(:description => "Neat!")

    expect(@category.errors[:description]).to eq(["is too short (minimum is 100 characters)"])
  end

  it "should be valid with valid attributes" do
    @category = FactoryGirl.create(:category)
    expect(@category).to be_valid
  end
end
