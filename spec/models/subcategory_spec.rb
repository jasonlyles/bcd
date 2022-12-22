require 'spec_helper'

describe Subcategory do
  before do
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
  end
  describe "find_live_subcategories" do
    it "should only find subcategories that are ready for the public" do
      #First subcategory is ready for public, 2nd one is not, so there should only be 1 category
      @subcategories = [FactoryGirl.create(:subcategory),
                     FactoryGirl.create(:subcategory, name: 'Star Wars', category: @category, code: 'SW', ready_for_public: 'f')
      ]
      @subcategories = Subcategory.find_live_subcategories

      expect(@subcategories.size).to eq(1)
    end
  end

  it "should not delete products" do
    subcategory = FactoryGirl.create(:subcategory, category: @category)
    FactoryGirl.create(:product)

    expect(lambda { subcategory.destroy }).to_not change(Product, :count)
  end

  it "should be valid with valid attributes" do
    subcat = FactoryGirl.create(:subcategory, category: @category)
    subcat.valid?

    expect(subcat).to be_valid
  end

  it "should not be valid without a name" do
    subcat = Subcategory.create(code: 'WX', category: @category)

    expect(subcat.errors[:name]).to eq(['can\'t be blank'])
  end

  it "should not be valid without a code" do
    subcat = Subcategory.create(name: 'Awesome', category: @category)

    expect(subcat.errors[:code]).to eq(['can\'t be blank'])
  end

  it "should not be valid if code is not unique" do
    subcat1 = FactoryGirl.create(:subcategory, category: @category)
    subcat2 = Subcategory.create(code: 'CV', category_id: @category.id)

    expect(subcat2.errors[:code]).to eq(['has already been taken'])
  end

  describe "self.model_code" do
    it "should suggest a model code based on the subcategory code and the number of products belonging to that subcategory" do
      subcategory = FactoryGirl.create(:subcategory, category: @category)
      model_code = Subcategory.model_code(subcategory.id)

      expect(model_code).to eq("#{subcategory.code}001")
    end

    it "should suggest a model code of XX010 for the 10th product in a subcategory" do
      subcategory = FactoryGirl.create(:subcategory, category: @category)
      9.times do |i|
        FactoryGirl.create(:product, product_code: "#{subcategory.code}00#{i+1}", name: "TEST#{i+1}")
      end
      model_code = Subcategory.model_code(subcategory.id)

      expect(model_code).to eq("#{subcategory.code}010")
    end

    it "should suggest a model code of XX100 for the 100th product in a subcategory" do
      subcategory = FactoryGirl.create(:subcategory, category: @category)
      99.times do |i|
        if i < 9
          FactoryGirl.create(:product, product_code: "#{subcategory.code}00#{i+1}", name: "TEST#{i+1}")
        else
          FactoryGirl.create(:product, product_code: "#{subcategory.code}0#{i+1}", name: "TEST#{i+1}")
        end
      end
      model_code = Subcategory.model_code(subcategory.id)

      expect(model_code).to eq("#{subcategory.code}100")
    end
  end
end
