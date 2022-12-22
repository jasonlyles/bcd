require 'spec_helper'
require 'carrierwave/test/matchers'

describe PdfUploader do
  include CarrierWave::Test::Matchers

  before do
    product = FactoryGirl.create(:product_with_associations)
    @uploader = PdfUploader.new(product, :pdf)
    @uploader.store!
    File.open(File.join(Rails.root, 'spec', 'support', 'pdfs', 'test.pdf')) { |f| @uploader.store!(f) }
  end

  after do
    @uploader.remove!
  end

  it 'should make the pdf readable and writable to owner, and others can read' do
    expect(@uploader).to have_permissions(0644)
  end

  it 'should only allow pdfs to be uploaded' do
    expect(lambda{@uploader.store!(File.open(File.join(Rails.root, 'spec', 'support', 'images', 'cv009_small.png')))}).to raise_error(CarrierWave::IntegrityError)
    expect(@uploader.extension_whitelist).to eq(['pdf'])
  end

  it 'should create a storage dir based on model category, subcategory and code' do
    expect(@uploader.store_dir).to match(/\/City\/Vehicles\/CB001/)
  end

  it 'should create a custom filename using a UUID' do
    expect(@uploader.filename).to match(/^\S+-test\.pdf$/)
  end
end
