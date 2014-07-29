require 'spec_helper'

describe PartsList do
  describe "PartsList.get_list" do
    it "should return the record for a parts list according to the list_type passed in" do
      @product_type = FactoryGirl.create(:product_type)
      category = FactoryGirl.create(:category)
      subcat = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      parts_lists = []
      parts_lists << FactoryGirl.create(:html_parts_list)
      parts_lists << FactoryGirl.create(:xml_parts_list)

      PartsList.get_list(parts_lists, 'xml')[0].id.should eq(2)
      PartsList.get_list(parts_lists, 'html')[0].id.should eq(1)
    end
  end

  describe "filename" do
    it 'should return the files basename' do
      parts_list = FactoryGirl.create(:html_parts_list)
      parts_list.name.to_s.should eq("/parts_lists/name/1/test.html")#match(/\/parts_lists\/name\/1\/test\.html/)
      fn = parts_list.filename
      fn.should eq('test.html')
    end
  end
end
