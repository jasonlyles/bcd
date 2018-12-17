class ProductType < ActiveRecord::Base
  has_many :products, dependent: :destroy # Make sure Product#destroy is getting called, and products with orders are not really getting destroyed
  has_one :image
  mount_uploader :image, ImageUploader
  process_in_background :image

  attr_accessible :name, :description, :ready_for_public, :image, :image_cache, :remove_image, :comes_with_description,
                  :comes_with_title, :digital_product

  validates :name, uniqueness: true, presence: true
  # validates :description, :presence => true, :length => {:maximum => 350, :minimum => 100}

  def self.find_live_product_types
    ProductType.where("ready_for_public = 't'")
  end

  def has_products?
    products = Product.where(['product_type_id = ?', id]).limit(1)
    products.empty? ? false : true
  end

  def destroy
    if has_products?
      # switch ready_for_public flag to 'f', effectively taking the product type
      # off the market, but leaving it in the database for reporting purposes
      self.ready_for_public = 'f'
      save
    else
      super
    end
  end
end
