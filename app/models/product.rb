# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :category
  belongs_to :subcategory
  belongs_to :product_type
  has_many :downloads
  has_many :images, dependent: :destroy
  has_many :parts_lists, dependent: :destroy
  mount_uploader :pdf, PdfUploader
  accepts_nested_attributes_for :images, allow_destroy: true
  accepts_nested_attributes_for :parts_lists, allow_destroy: true

  # attr_accessible :category_id, :description, :discount_percentage, :name, :pdf, :pdf_cache,
  # :price, :product_code, :product_type_id, :ready_for_public, :remove_pdf,
  # :subcategory_id, :tweet, :free, :quantity, :alternative_build, :youtube_url, :images_attributes,
  # :parts_lists_attributes, :featured, :designer

  validates :product_code, uniqueness: true, presence: true
  validates :product_type_id, presence: true
  validates :subcategory_id, presence: true
  validates :category_id, presence: true
  validates :description, presence: true, length: { minimum: 100, maximum: 900 }
  validates :price, presence: true, numericality: true
  validates :price, price_greater_than_zero: true
  validates :price, price_is_zero_for_freebies: true
  validates :product_code, product_code_matches_pattern: true
  validates :name, presence: true, uniqueness: true
  validates :tweet, length: { maximum: 97 }
  validates :discount_percentage, numericality: true, allow_blank: true
  validates :discount_percentage, inclusion: { in: 0..90, message: 'Percentage must be between 0 and 90' }, allow_blank: true
  # This line calls a custom validator that looks to make sure that there is a pdf attached to this object before
  # letting this product be made available to the public
  validates :ready_for_public, pdf_exists: true

  scope :ready, -> { where(ready_for_public: true).includes(:category).includes(:subcategory) }
  scope :featured, -> { where(featured: true) }
  scope :in_stock, -> { where('quantity > 0') } # Maybe set up to use only physical products, and not digital products
  scope :instructions, -> { Product.joins(:product_type).where("product_types.name='Instructions'") }
  scope :ready_instructions, -> { ready.instructions }
  scope :sellable_instructions, -> { ready_instructions.where(free: false) }

  def self.find_all_by_price(price)
    price = 0 if price == 'free'
    Product.ready_instructions.where(['price=?', price.to_f])
  end

  def self.sort_by_price
    blk = ->(hash, key) { hash[key] = Hash.new(&blk) }
    price_groups = Hash.new(&blk)
    products = Product.ready_instructions.order(:price)
    products.each do |product|
      if price_groups.key?(product.price.to_i.to_s)
        price_groups[product.price.to_i.to_s]['count'] += 1
      else
        price_groups[product.price.to_i.to_s]['count'] = 1
      end
    end
    array = []
    price_groups.each do |price_group|
      array << [price_group[0].to_i, price_group[1]['count']]
    end
    array
  end

  def self.alternative_builds
    Product.sellable_instructions.where("alternative_build = 't'")
  end

  def self.find_products_for_sale
    # At first, ordering by name will be fine. Eventually I might want to order by popularity. Maybe I can have a script that
    # #runs once a day/week that gets total order of sales and updates a 'total_sales' column in the products table.
    # #Then I can use that for ordering
    Product.ready.where("free != 't' and quantity > 0")
  end

  def self.find_instructions_for_sale
    Product.sellable_instructions
  end

  def self.freebies
    Product.ready_instructions.where("free = 't'")
  end

  def find_live_products_from_same_category
    Product.ready.where(["free != 't' and quantity >= 1 and category_id = ? and id <> ?", category_id, id]).limit(4)
  end

  def orders?
    LineItem.where(['product_id = ?', p.id]).exists?
  end

  def destroy
    if orders?
      # switch ready_for_public flag to 'f', effectively taking the product off the market, but leaving it in the
      # database for reporting purposes
      self.ready_for_public = 'f'
      save
    else
      super
    end
  end

  def decrement_quantity(amount)
    return if product_type.digital_product?

    self.quantity -= amount
    save
  end

  def physical_product?
    !digital_product?
  end

  def digital_product?
    if product_type
      product_type.digital_product?
    else
      true # If there is no product_type, this is a new record, return true to make digital-only fields available in the new form
    end
  end

  def includes_instructions?
    %w[Instructions Kits Models].include?(product_type.name)
  end

  def quantity_available?(amount)
    self.quantity >= amount
  end

  def out_of_stock?
    self.quantity.zero?
  end

  def base_product_code(code = nil)
    if code
      code.match(/^[A-Z]{2}\d{3}/).to_s
    else
      product_code.match(/^[A-Z]{2}\d{3}/).to_s
    end
  end

  def self.find_by_base_product_code(product_code)
    product = Product.new
    find_by_product_code(product.base_product_code(product_code.upcase))
  end

  def main_image
    return images[0].url unless images.blank?

    nil
  end

  def code_and_name
    "#{product_code} #{name}"
  end

  def retire
    self.category_id = Category.find_by_name('Retired').id
    self.subcategory_id = Subcategory.find_by_name('Retired').id
    self.ready_for_public = false
    save
  end

  def discounted_price
    # Assumes discount_percentage is stored as an integer. i.e. 25, which means 25%
    discount_percentage? ? (price * (100 - discount_percentage) / 100.to_f) : price
  end

  # TODO: Make sure that removing a product not only deletes the image in the database, but also in Amazon S3
end
