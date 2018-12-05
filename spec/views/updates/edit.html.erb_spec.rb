require 'spec_helper'

describe 'updates/edit.html.erb' do
  before(:each) do
    @update = assign(:update, stub_model(Update,
                                         title: 'MyString',
                                         description: 'MyString',
                                         body: 'MyText',
                                         image: 'MyString'))
  end

  it 'renders the edit update form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form', action: update_path(@update), method: 'post' do
      assert_select 'input#update_title', name: 'update[title]'
      assert_select 'input#update_description', name: 'update[description]'
      assert_select 'textarea#update_body', name: 'update[body]'
      assert_select 'input#update_image', name: 'update[image]'
    end
  end
end
