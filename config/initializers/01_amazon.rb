require "#{Rails.root}/lib/config/amazon_config.rb"

AmazonConfig.configure do |config|
  config.instruction_bucket = ENV['BCD_S3_INSTRUCTION_BUCKET']
  config.image_bucket = ENV['BCD_S3_IMAGE_BUCKET']
  config.access_key = ENV['BCD_S3_KEY']
  config.secret = ENV['BCD_S3_SECRET']
end