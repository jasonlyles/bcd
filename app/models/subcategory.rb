# frozen_string_literal: true

class Subcategory < ApplicationRecord
  belongs_to :category
  has_many :products # Deleting a subcat should not delete it's products

  # attr_accessible :category_id, :code, :description, :name, :ready_for_public

  validates :name, :presence => true
  validates :code, :presence => true
  validates :code, :uniqueness => true

  def self.find_live_subcategories
    Subcategory.where("ready_for_public = 't'").order('name')
  end

  def self.model_code(subcategory_id)
    subcategory_code = Subcategory.find(subcategory_id).code
    count = Product.where('subcategory_id=?', subcategory_id).count
    count += 1
    numeric_code = if count < 10
                     "00#{count}"
                   elsif count < 100
                     "0#{count}"
                   else
                     count.to_s
                   end
    "#{subcategory_code.upcase}#{numeric_code}"
  end

  def name_and_category_name
    "#{category.name}/#{name}"
  end
end
