require 'spec_helper'

describe 'updates/new.html.erb' do
  before(:each) do
    assign(:update, stub_model(Update,
                               title: 'MyString',
                               description: 'MyString',
                               body: 'MyText',
                               image: 'MyString').as_new_record)
  end

  it 'renders new update form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form', action: updates_path, method: 'post' do
      assert_select 'input#update_title', name: 'update[title]'
      assert_select 'input#update_description', name: 'update[description]'
      assert_select 'textarea#update_body', name: 'update[body]'
      assert_select 'input#update_image', name: 'update[image]'
    end
  end
end
