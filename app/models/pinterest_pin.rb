# frozen_string_literal: true

class PinterestPin < ApplicationRecord
  belongs_to :pinterest_board
  belongs_to :product
end
