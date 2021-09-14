class Color < ActiveRecord::Base
  has_many :elements
  has_many :parts, through: :elements
end
