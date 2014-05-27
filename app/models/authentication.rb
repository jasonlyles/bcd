class Authentication < ActiveRecord::Base
  belongs_to :user

  attr_accessible :user_id, :provider, :uid

  validates :provider, :presence => true
  validates :uid, :presence => true
end
