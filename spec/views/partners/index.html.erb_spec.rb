require 'spec_helper'

describe 'partners/index.html.erb' do
  before(:each) do
    assign(:partners, [
             stub_model(Partner,
                        name: 'Name',
                        url: 'Url',
                        contact: 'Contact'),
             stub_model(Partner,
                        name: 'Name',
                        url: 'Url',
                        contact: 'Contact')
           ])
  end

  it 'renders a list of partners' do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'tr>td', text: 'Name'.to_s, count: 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'tr>td', text: 'Url'.to_s, count: 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'tr>td', text: 'Contact'.to_s, count: 2
  end
end
