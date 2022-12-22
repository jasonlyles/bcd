# frozen_string_literal: true

class Authentication < ApplicationRecord
  belongs_to :user

  # attr_accessible :user_id, :provider, :uid

  validates :provider, presence: true
  validates :uid, presence: true
end
