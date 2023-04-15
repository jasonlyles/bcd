# frozen_string_literal: true

class Radmin < ApplicationRecord
  audited except: %i[created_at updated_at current_sign_in_at last_sign_in_at sign_in_count]
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :timeoutable, :trackable, :validatable, :lockable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me
end
