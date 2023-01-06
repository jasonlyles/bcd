require 'spec_helper'

describe ApplicationHelper do
  describe 'snippet' do
    it 'should show only a snippet of a longer string' do
      expect(helper.snippet('Brick City Depot will soon take over the custom lego instruction world!', word_count: 5)).to eq('Brick City Depot will soon...')
    end
  end

  describe 'featured_items' do
    it 'should get a random product for featuring' do
      @product_type = FactoryBot.create(:product_type)
      @category = FactoryBot.create(:category)
      @subcategory = FactoryBot.create(:subcategory)
      @products = [FactoryBot.create(:product, featured: 't'),
                   FactoryBot.create(:product,
                                      name: 'Grader',
                                      product_type_id: @product_type.id,
                                      product_code: 'WC002',
                                      description: 'Winter Village Grader... are you kidding? w00t! Plow your winter village to the ground and then flatten it out with this sweet grader.',
                                      price: '5.00',
                                      ready_for_public: 't',
                                      featured: 't')]

      expect(helper.featured_items[0].name).to match(/Colonial Revival House|Grader/)
    end
  end

  describe 'host_url' do
    it 'should return the host url' do
      expect(helper.host_url).to eq('http://test.host')
    end
  end
end
