require 'spec_helper'

describe 'categories/edit.html.erb' do
  before(:each) do
    @category = assign(:category, stub_model(Category,
                                             name: 'MyString',
                                             description: 'Description of 100 or more characters. This should get me up to 100 characters by doing things like this: blah blah blah blah etc etc.',
                                             ready_for_public: 't'))
  end

  it 'renders the edit category form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form', action: category_path(@category), method: 'post' do
      assert_select 'input#category_name', name: 'category[name]'
      assert_select 'textarea#category_description', name: 'category[description]'
      assert_select 'input#category_ready_for_public', name: 'category[ready_for_public]'
    end
  end
end
