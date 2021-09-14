require 'spec_helper'

describe BricklinkXmlParser do

  before do
    @xml = File.read(File.join(Rails.root, 'spec', 'support', 'parts_lists', 'full_bricklink.xml'))
    @element_ids = ["2357_72","2412b_0","2412b_72","2420_15","2431_0","2431_15","2431_71","2432_0","2436_71","2555_72","2584_0",
      "2585_71","3002_0","3003_72","3004_0","3004_15","3004_72","3005_15","3009_15","30104_72","3010_0","3020_0","3020_71",
      "3021_72","3022_71","3022_72","3023_0","3023_15","3023_71","3024_0","3024_15","3030_71","3031_71","3033_72","3034_71",
      "3036_72","30395_72","30414_71","3065_40","3068b_0","3069b_0","3069b_15","3069b_4","3069b_57","3069b_71","3069bpx19_71",
      "3070b_0","32000_72","32028_71","32270_0","3623_72","3660_72","3665_15","3666_0","3666_15","3666_71","3666_72","3700_72",
      "3706_0","3708_0","3710_0","3710_71","3710_72","3713_71","3795_0","3795_71","3795_72","3829c01_15","3832_71","4006_0",
      "4073_36","4073_46","4073_57","4073_72","4085a_15","4095_71","4162_4","4162_71","4176_40","4265c_71","4274_71","4275_0",
      "44675_0","4488_71","4531_0","4532_0","4533_15","4589_57","4592c02_71","48336_15","4865_15","50745_72","52031_15",
      "52107_0","54200_0","54200_15","54200_47","54200_57","54200_71","6014b_71","6015_0","60470_0","6091_71","6541_15",
      "6636_0","6636_71","6636_72","x77ac50_0"]
  end

  describe 'parse' do
    it 'should get all parts from the bricklink xml and assemble a hash with data about every part' do
      # It appears that fixtures are getting wiped out, maybe by database cleaner?
      # Anyways, this little hack in here gets colors set up for this test.
      Color.destroy_all
      ActiveRecord::FixtureSet.create_fixtures(Rails.root.join('spec', 'fixtures'), 'colors')
      bricklink_xml_parser = BricklinkXmlParser.new(@xml)
      elements = bricklink_xml_parser.parse
      total_parts_count = 0
      elements.map { |k, v| total_parts_count += v['quantity'] }

      expect(elements.keys.length).to eq(108)
      expect(elements.keys.sort).to eq(@element_ids)
      expect(total_parts_count).to eq(279)
    end
  end
end
