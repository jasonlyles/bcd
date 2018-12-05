require 'spec_helper'

describe 'subcategories/index.html.erb' do
  before(:each) do
    @subcategories = []
    subcategory1 = assign(:subcategory, stub_model(Subcategory,
                                                   name: 'Banditos',
                                                   code: 'MB',
                                                   description: 'Mexican Banditos are awesome',
                                                   category_id: 1))
    category = FactoryGirl.create(:category, name: 'Winter Village', description: 'Looking for 100 or more characters here. Blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah')
    subcategory1.category_id = category.id
    subcategory1.save!
    @subcategories << subcategory1

    subcategory2 = assign(:subcategory, stub_model(Subcategory,
                                                   name: 'Buildings',
                                                   code: 'CB',
                                                   description: 'City buildings are neat',
                                                   category_id: 1))
    subcategory2.category_id = category.id
    subcategory2.save!
    @subcategories << subcategory2
  end

  it 'renders a list of subcategories' do
    render
    assert_select 'tr>td', text: 'Winter Village', count: 2
    assert_select 'tr>td', text: 'Banditos', count: 1
    assert_select 'tr>td', text: 'Buildings', count: 1
    assert_select 'tr>td', text: 'MB', count: 1
    assert_select 'tr>td', text: 'CB', count: 1
  end
end
