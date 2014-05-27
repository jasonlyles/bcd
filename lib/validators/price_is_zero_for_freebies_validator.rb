class PriceIsZeroForFreebiesValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if object.free == true && value.to_i > 0
      object.errors[attribute] << (options[:message] || " Freebies should be $0")
    end
  end
end