# frozen_string_literal: true

class Radmin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :timeoutable, :trackable, :validatable, :lockable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me

  def valid_password?(password)
    valid_password?(password)
  end
end
