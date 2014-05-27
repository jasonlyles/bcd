class PriceGreaterThanZeroValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if value.to_i == 0 && object.free == false
      object.errors[attribute] << (options[:message] || " Hey... Don't you want to make some money on this?")
    end
  end
end