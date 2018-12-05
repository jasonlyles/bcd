require 'spec_helper'

describe 'categories/index.html.erb' do
  before(:each) do
    assign(:categories, [
             stub_model(Category,
                        name: 'Name',
                        description: 'Description of 100 or more characters. This should get me up to 100 characters by doing things like this: blah blah blah blah etc etc.',
                        ready_for_public: 't'),
             stub_model(Category,
                        name: 'Name',
                        description: 'Description of 100 or more characters. This should get me up to 100 characters by doing things like this: blah blah blah blah etc etc.',
                        ready_for_public: 'f')
           ])
  end

  it 'renders a list of categories' do
    render

    assert_select 'tr>td', text: 'Name', count: 2
    assert_select 'tr>td', text: /Description of 100 or more/, count: 2
    assert_select 'tr>td', text: 'true', count: 1
    assert_select 'tr>td', text: 'false', count: 1
  end
end
