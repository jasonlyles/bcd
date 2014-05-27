class ProductCodeMatchesPatternValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if object.product_type.name == "Instructions"
      if !value.match(/^[A-Z]{2}\d{3}$/)
        object.errors[attribute] << (options[:message] || "Instruction product codes must follow the pattern CB002.")
      end
    elsif object.product_type.name == "Models"
      if !value.match(/^[A-Z]{2}\d{3}M$/)
        object.errors[attribute] << (options[:message] || "Model product codes must follow the pattern CB002M.")
      else
        if Product.find_by_base_product_code(value).nil?
          object.errors[attribute] << (options[:message] || "Model product codes must have a base model with a product code of #{value.match(/^[A-Z]{2}\d{3}/)}")
        end
      end
    elsif object.product_type.name == "Kits"
      if !value.match(/^[A-Z]{2}\d{3}K$/)
        object.errors[attribute] << (options[:message] || "Kit product codes must follow the pattern CB002K.")
      else
        if Product.find_by_base_product_code(value).nil?
          object.errors[attribute] << (options[:message] || "Kit product codes must have a base model with a product code of #{value.match(/^[A-Z]{2}\d{3}/)}")
        end
      end
    end
  end
end