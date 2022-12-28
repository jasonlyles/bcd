# frozen_string_literal: true

class PriceIsZeroForFreebiesValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    object.errors.add(attribute, message: options[:message] || ' Freebies should be $0') if object.free == true && value.to_i.positive?
  end
end
