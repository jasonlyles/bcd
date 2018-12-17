class Category < ActiveRecord::Base
  has_many :subcategories, dependent: :destroy
  has_many :products # Deleting a cat should not delete it's products
  has_one :image
  mount_uploader :image, ImageUploader
  process_in_background :image

  attr_accessible :name, :description, :ready_for_public, :image, :image_cache, :remove_image

  validates :name, uniqueness: true, presence: true
  validates :description, presence: true, length: { maximum: 350, minimum: 100 }

  def self.find_live_categories
    Category.where("ready_for_public = 't'").order('name')
  end

  def has_products?
    products = Product.where(['category_id = ?', id]).limit(1)
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
