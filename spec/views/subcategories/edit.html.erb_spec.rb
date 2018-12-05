require 'spec_helper'

describe 'subcategories/edit.html.erb' do
  before(:each) do
    @subcategory = assign(:subcategory, stub_model(Subcategory,
                                                   name: 'MyString',
                                                   searched_on_count: 1,
                                                   category_id: 1))
    category = FactoryGirl.create(:category)
    @categories = []
    @categories << category
  end

  it 'renders the edit subcategory form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form', action: subcategory_path(@subcategory), method: 'post' do
      assert_select 'input#subcategory_name', name: 'subcategory[name]'
      assert_select 'input#subcategory_code', name: 'subcategory[code]'
      assert_select 'select#subcategory_category_id', name: 'subcategory[category_id]'
      assert_select 'textarea#subcategory_description', name: 'subcategory[description]'
    end
  end
end
