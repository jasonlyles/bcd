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

  describe 'decorate_boolean' do
    it 'should make a boolean a bit nicer' do
      expect(helper.decorate_boolean(true)).to eq('<i class="text-success fas fa-check"></i>')
      expect(helper.decorate_boolean(false)).to eq('<i class="text-danger fas fa-times"></i>')
    end
  end

  describe 'meta_keywords' do
    it 'should retrieve meta keywords for the doc' do
      expect(helper.meta_keywords).to eq('custom lego instructions, lego custom instructions, lego modular buildings, lego city instructions, brick city depot, brickcitydepot, lego chili\'s, lego chilis')
    end
  end

  describe 'meta_description' do
    it 'should retrieve meta description for the doc' do
      expect(helper.meta_description).to eq('Custom Lego instructions and kits, with focus mainly on modular buildings.')
    end
  end

  describe 'opengraph_metadata' do
    it 'should retrieve opengraph metadata for the doc' do
      expect(helper.opengraph_metadata).to eq(
        app_id: 190_041_747_696_738,
        description: 'Brick City Depot sells custom Lego instructions, models and kits. Featuring models based on the Lego Modular Buildings line.',
        image: 'http://test.host/assets/logo_200x200-31ac55a9f6969519da50b10d2f88d7eadde1e0e1249e3c6fbad5b9c7bc3994e2.png',
        site_name: 'Brick City Depot',
        title: 'Brick City Depot. The internets\' best source for custom Lego instructions.',
        url: 'http://test.host'
      )
    end
  end
end
