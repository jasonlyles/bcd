require 'spec_helper'

describe 'categories/show.html.erb' do
  before(:each) do
    @category = assign(:category, stub_model(Category,
                                             name: 'Name',
                                             description: 'Description of 100 or more characters. This should get me up to 100 characters by doing things like this: blah blah blah blah etc etc.',
                                             ready_for_public: 'true'))
  end

  it 'renders attributes in <p>' do
    render

    expect(rendered).to match(/Name/)
    expect(rendered).to match(/blah blah blah/)
    expect(rendered).to match(/Ready for Public/)
  end
end
