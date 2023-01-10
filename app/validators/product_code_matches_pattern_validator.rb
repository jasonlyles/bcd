# frozen_string_literal: true

class ProductCodeMatchesPatternValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    case object.product_type&.name
    when 'Instructions'
      object.errors.add(attribute, message: options[:message] || 'Instruction product codes must follow the pattern CB002.') unless value.match(/^[A-Z]{2}\d{3}$/)
    when 'Models'
      check_model_code(object, attribute, value, 'Model', 'M')
    when 'Kits'
      check_model_code(object, attribute, value, 'Kit', 'K')
    else
      object.errors.add(attribute, message: options[:message] || 'Invalid Product Type')
    end
  end

  # rubocop:disable Style/NegatedIfElseCondition
  def check_model_code(object, attribute, value, product_type, code_suffix)
    if !value.match(/^[A-Z]{2}\d{3}#{code_suffix}$/)
      object.errors.add(attribute, message: options[:message] || "#{product_type} product codes must follow the pattern CB002#{code_suffix}.")
    else
      object.errors.add(attribute, message: options[:message] || "#{product_type} product codes must have a base model with a product code of #{value.match(/^[A-Z]{2}\d{3}/)}") unless Product.find_by_base_product_code(value)
    end
  end
  # rubocop:enable Style/NegatedIfElseCondition
end