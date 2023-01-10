# frozen_string_literal: true

class PriceGreaterThanZeroValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    object.errors.add(attribute, message: options[:message] || ' Hey... Don\'t you want to make some money on this?') if value.to_i.zero? && object.free == false
  end
end
