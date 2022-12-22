# frozen_string_literal: true

class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or ImageScience support:
  include CarrierWave::MiniMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog

  def fog_directory
    AmazonConfig.config.image_bucket
  end

  def fog_public
    true
  end
  # def s3_bucket
  #  AmazonConfig.config.image_bucket
  # end

  # def s3_access_policy
  #  :public_read
  # end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "images/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # def filename
  #  @name ||= "#{uuid}-#{super}" if original_filename.present? and super.present?
  # end

  # def uuid
  #  SecureRandom.hex(20)
  # end

  # def url
  #   Overriding this to hide full path to where the images are stored in S3, and to force the images to be served through the cloudfront. I'm sure there's a better way than this, and this might
  #   screw something else up, but until I can figure out a better way, I'm probably going to leave it like this.
  #  "http://images.brickcitydepot.com/#{store_dir}/#{model.url.to_s.match(/\w+\.\w+$/).to_s}"
  # end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  process resize_to_fit: [700, 700]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb do
    process resize_to_fit: [100, 100]
  end

  version :medium do
    process resize_to_fit: [300, 300]
  end

  version :large do
    process resize_to_fit: [600, 600]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w[jpg jpeg gif png]
  end

  # A content_type_allowlist is the only form of allowlist or denylist supported
  # by CarrierWave that can effectively mitigate against CVE-2016-3714. (ImageTragick)
  def content_type_allowlist
    [/image\//]
  end

  # Override the filename of the uploaded files:
  # def filename
  #   "something.jpg" if original_filename
  # end
end
