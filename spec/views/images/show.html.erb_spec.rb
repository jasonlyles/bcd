require 'spec_helper'

describe 'images/show.html.erb' do
  before(:each) do
    # @image = assign(:image, stub_model(Image))
    @image = FactoryGirl.create(:image)
  end

  it 'renders attributes in <p>' do
    render
  end
end
