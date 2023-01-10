# frozen_string_literal: true

class PdfExistsValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    object.errors.add(attribute, message: options[:message] || ': Can\'t allow you to make a product live before you upload the PDF.') if value == true && object.pdf.blank? && object.product_type.name == 'Instructions'
  end
end
