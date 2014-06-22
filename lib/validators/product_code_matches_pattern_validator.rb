class ProductCodeMatchesPatternValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if object.product_type.name == "Instructions"
      if !value.match(/^[A-Z]{2}\d{3}$/)
        object.errors[attribute] << (options[:message] || "Instruction product codes must follow the pattern CB002.")
      end
    elsif object.product_type.name == "Models"
      check_model_code(object, attribute, value, 'Model', 'M')
    elsif object.product_type.name == "Kits"
      check_model_code(object, attribute, value, 'Kit', 'K')
    end
  end

  def check_model_code(object, attribute, value, product_type,code_suffix)
    if !value.match(/^[A-Z]{2}\d{3}#{code_suffix}$/)
      object.errors[attribute] << (options[:message] || "#{product_type} product codes must follow the pattern CB002#{code_suffix}.")
    else
      unless Product.find_by_base_product_code(value)
        object.errors[attribute] << (options[:message] || "#{product_type} product codes must have a base model with a product code of #{value.match(/^[A-Z]{2}\d{3}/)}")
      end
    end
  end
end