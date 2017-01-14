class PdfExistsValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if value == true && object.pdf.blank? && object.product_type.name == "Instructions"
      object.errors[attribute] << (options[:message] || ": Can't allow you to make a product live before you upload the PDF.")
    end
  end
end
