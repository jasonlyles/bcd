# frozen_string_literal: true

class Email
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  # contact_info exists here only for a simple honeypot on the contact form.
  attr_accessor :name, :body, :email_address, :contact_info

  validates :name, :body, :email_address, :presence => true
  validates :email_address, :format => { :with => %r{.+@.+\..+} }, :allow_blank => true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
