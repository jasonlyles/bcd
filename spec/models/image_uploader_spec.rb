require 'spec_helper'
require 'carrierwave/test/matchers'

describe ImageUploader do
  include CarrierWave::Test::Matchers

  before do
    product = FactoryGirl.create(:product_with_associations)
    @image = FactoryGirl.create(:image, product: product)
    ImageUploader.enable_processing = true
    @uploader = ImageUploader.new(@image, :url)
    File.open(File.join(Rails.root, 'spec', 'support', 'images', 'cv009_small.png')) { |f| @uploader.store!(f) }
  end

  after do
    ImageUploader.enable_processing = false
    @uploader.remove!
  end

  context 'the thumb version' do
    it "should scale down the image to be exactly 100x100 pixels" do
      expect(@uploader.thumb).to have_dimensions(100,100)
    end
  end

  context 'the medium version' do
    it 'should scale down a landscape image to fit within 300 by 300 pixels' do
      expect(@uploader.medium).to be_no_larger_than(300,300)
    end
  end

  it 'should make the image readable and writable to owner, and readable to everyone else' do
    expect(@uploader).to have_permissions(0644)
  end

  it 'should only allow jpg, jpeg, gif and png to be uploaded' do
    expect(lambda { @uploader.store!(File.open(File.join(Rails.root, 'spec', 'support', 'pdfs', 'fake_pdf.pdf'))) }).to raise_error(CarrierWave::IntegrityError)
    expect(@uploader.extension_whitelist).to eq(['jpg','jpeg','gif','png'])
  end

  it 'should create a storage dir based on model category, subcategory, product code and model ID' do
    expect(@uploader.store_dir).to eq('images/image/url/1')
  end
end
