# frozen_string_literal: true

class PdfUploader < CarrierWave::Uploader::Base
  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    extra_dir = Rails.env.test? ? 'test/' : ''
    "pdfs/#{extra_dir}#{model.category.name.despace}/#{model.subcategory.name.despace}/#{model.product_code}"
  end

  def filename
    @name ||= "#{uuid}-#{super}" if original_filename.present? && super.present?
  end

  def uuid
    SecureRandom.hex(20)
  end

  def fog_directory
    AmazonConfig.config.instruction_bucket
  end

  def fog_attributes
    { 'Content-Disposition' => 'attachment' }
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end
  def extension_whitelist
    %w[pdf]
  end
  # Override the filename of the uploaded files:
  # def filename
  #   "something.jpg" if original_filename
  # end
end
