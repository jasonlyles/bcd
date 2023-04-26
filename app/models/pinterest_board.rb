# frozen_string_literal: true

class PinterestBoard < ApplicationRecord
  has_many :pinterest_pins, dependent: :destroy
end
