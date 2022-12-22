# frozen_string_literal: true

class UserPartsList < ApplicationRecord
  belongs_to :parts_list
  belongs_to :user

  validates :parts_list_id, uniqueness: { scope: :user_id }
  validates :parts_list_id, presence: true
  validates :user_id, presence: true
end
