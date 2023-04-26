# frozen_string_literal: true

class Product < ApplicationRecord
  audited except: %i[created_at updated_at]
  acts_as_ordered_taggable
  include ActiveModel::Serialization

  belongs_to :category
  belongs_to :subcategory
  belongs_to :product_type
  has_many :downloads
  has_many :images, -> { order(position: :asc) }, dependent: :destroy
  has_many :parts_lists, dependent: :destroy
  has_many :pinterest_pins, dependent: :destroy
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
  scope :ready_instructions, -> { ready.instructions }
  scope :sellable_instructions, -> { where(ready_for_public: true).instructions.where(free: false) }

  # TODO: Change this to super.merge like in the email_campaign model.
  def attributes
    {
      'id' => id,
      'name' => name,
      'product_type' => product_type.name,
      'category' => category.name,
      'subcategory' => subcategory.name,
      'description' => description,
      'youtube_url' => youtube_url,
      'quantity' => quantity,
      'free?' => free,
      'discount_percentage' => discount_percentage,
      'price' => price,
      'discounted_price' => discounted_price,
      'product_code' => product_code,
      'code_and_name' => code_and_name
    }
  end

  ransacker :has_etsy_listing_id,
            formatter: proc { |boolean|
              results = Product.has_etsy_listing_for_ransack?(boolean).map(&:id)
              results.present? ? results : nil
            }, splat_params: true do |parent|
    parent.table[:id]
  end

  # rubocop:disable Naming/PredicateName
  def self.has_etsy_listing_for_ransack?(boolean)
    if boolean == '1'
      where('etsy_listing_id IS NOT NULL')
    else
      where('etsy_listing_id IS NULL')
    end
  end
  # rubocop:enable Naming/PredicateName

  def self.instructions
    Product.joins(:product_type).where("product_types.name='Instructions'")
  end

  def self.find_all_by_price(price)
    price = 0 if price == 'free'
    Product.ready_instructions.where(['price=?', price.to_f])
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
    Product.sellable_instructions.where(['category_id = ? and products.id <> ?', category_id, id]).limit(4)
  end

  def orders?
    LineItem.where(['product_id = ?', id]).exists?
  end

  def base_pinterest_pinnable?
    base_product_board = PinterestBoard.find_by_topic('base_product')
    return false if base_product_board.blank?

    etsy_listing_url.present? && !pinterest_pins.where(pinterest_board_id: base_product_board.id).present?
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

  # :nocov:
  def etsy_wrapped_title
    "Custom Lego Instructions: #{name} - No Bricks Included - Please read description"
  end
  # :nocov:

  # :nocov:
  def etsy_wrapped_description
    <<~TEXT
      This listing is for a link to download a PDF of instructions and access to an interactive parts list to help you gather the pieces you need to build the model. The PDF that you can download through this listing includes helpful links and email addresses to contact us. No Lego bricks are included.

      The download link will be sent via email to the email address you have registered with Etsy.

      What you will receive:
      - You will get a link to download the instructions PDF, which you can download up to 5 times.
      - Unlimited access to an interactive parts list to help assemble the pieces you need to build the model.
      - Access to a new user tutorial and a frequently asked questions page if you're having trouble getting started.
      - We also have a contact form on our site you can use to get in direct contact with us if the new user tutorial and frequently asked questions pages aren't enough help.

      Product Description:

      #{description}

      This is NOT a LEGO® product. LEGO® is a trademark of the LEGO Group of companies which does not sponsor, authorize or endorse this listing.
    TEXT
  end
  # :nocov:

  def assemble_changes_since_last_etsy_update
    return nil if etsy_updated_at.blank?

    changes_since_last_etsy_update = []
    # First, let's get changes to product attributes
    assemble_product_attribute_changes_since_last_etsy_update.each do |change|
      changes_since_last_etsy_update << change
    end

    # Second, let's see if any tags have changed.
    changes_since_last_etsy_update << assemble_tag_changes_since_last_etsy_update

    # Next, let's look for new images
    assemble_new_image_since_last_etsy_update.each do |change|
      changes_since_last_etsy_update << change
    end

    # Finally, let's look for image re-ordering
    changes_since_last_etsy_update << assemble_images_reordered_since_last_etsy_update

    changes_since_last_etsy_update.compact
  end

  private

  def assemble_product_attribute_changes_since_last_etsy_update
    changes_since_last_etsy_update = []
    keys_of_interest = %w[description product_code name price]
    audits_since_last_etsy_update = audits.where("created_at >= '#{etsy_updated_at}'")
    audits_since_last_etsy_update.each do |audit|
      audit.audited_changes.each_key do |key|
        changes_since_last_etsy_update << ["#{key} changed", audit.created_at] if keys_of_interest.include?(key)
      end
    end

    changes_since_last_etsy_update
  end

  def assemble_tag_changes_since_last_etsy_update
    changes_since_last_etsy_update = nil
    updated_taggings = taggings.order(created_at: :desc).limit(13).where("created_at >= '#{etsy_updated_at}'")
    changes_since_last_etsy_update = ['tags changed', updated_taggings.first.created_at] if updated_taggings.present?

    changes_since_last_etsy_update
  end

  def assemble_new_image_since_last_etsy_update
    changes_since_last_etsy_update = []
    new_images = images.where("etsy_listing_image_id IS NULL AND created_at >= '#{etsy_updated_at}'")
    new_images.each do |image|
      changes_since_last_etsy_update << ['image added', image.created_at]
    end

    changes_since_last_etsy_update
  end

  def assemble_images_reordered_since_last_etsy_update
    changes_since_last_etsy_update = nil
    found_position_change = false
    images.each do |image|
      break if found_position_change == true

      audits_since_last_update = image.audits.where("created_at >= '#{etsy_updated_at}'")
      audits_since_last_update.each do |audit|
        break if found_position_change == true

        if audit.action == 'update' && audit.audited_changes.keys.include?('position')
          changes_since_last_etsy_update = ['images re-ordered', audit.created_at]
          found_position_change = true
        end
      end
    end

    changes_since_last_etsy_update
  end
end
