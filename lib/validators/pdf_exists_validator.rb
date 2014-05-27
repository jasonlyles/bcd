class PdfExistsValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    #I don't really like doing this, but I haven't figured out yet how to fake a file upload for the seeding. I don't want to upload a file every time I reseed, since I do it often in dev.
    #TODO: Take away the ENV condition. Add the pdfs to the seeds file.
    if Rails.env.production? || Rails.env.staging? || Rails.env.test?
      if value == true && object.pdf.blank? && object.product_type.name == "Instructions"
        object.errors[attribute] << (options[:message] || ": Can't allow you to make a product live before you upload the PDF.")
      end
    end
  end
end
