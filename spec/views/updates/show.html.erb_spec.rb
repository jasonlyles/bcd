require 'spec_helper'

describe 'updates/show.html.erb' do
  before(:each) do
    @update = assign(:update, stub_model(Update,
                                         title: 'Title',
                                         description: 'Description',
                                         body: 'MyText',
                                         image: 'Image'))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Image/)
  end
end
