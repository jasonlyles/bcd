class Email

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :body, :email_address

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