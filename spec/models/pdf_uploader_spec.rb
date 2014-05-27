require 'carrierwave/test/matchers'

describe PdfUploader do
  include CarrierWave::Test::Matchers

  before do
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
    @subcategory = FactoryGirl.create(:subcategory)
    @product = FactoryGirl.create(:product)
    @uploader = PdfUploader.new(@product, :pdf)
    @uploader.store!(File.open(File.join(Rails.root, 'spec', 'support', 'pdfs', 'test.pdf')))
  end

  after do
    @uploader.remove!
  end

  it 'should make the pdf readable and writable to owner, and others can read' do
    @uploader.should have_permissions(0644)
  end

  it 'should only allow pdfs to be uploaded' do
    lambda{@uploader.store!(File.open(File.join(Rails.root, 'spec', 'support', 'images', 'cv009_small.png')))}.should raise_error(CarrierWave::IntegrityError)
    @uploader.extension_white_list.should == ['pdf']
  end

  it 'should create a storage dir based on model category, subcategory and code' do
    @uploader.store_dir.should == 'pdfs/City/Vehicles/CB001'
  end

  it 'should create a custom filename using a UUID' do
    @uploader.filename.should match(/^\S+-test\.pdf$/)
  end
end