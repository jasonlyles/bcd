require 'spec_helper'

describe 'partners/show.html.erb' do
  before(:each) do
    @partner = assign(:partner, stub_model(Partner,
                                           name: 'Name',
                                           url: 'Url',
                                           contact: 'Contact'))
  end

  it 'renders attributes in <p>' do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Url/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Contact/)
  end
end
