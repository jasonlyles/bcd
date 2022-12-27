CarrierWave.configure do |config|
  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
    config.ignore_integrity_errors = false
    config.ignore_processing_errors = false
    config.ignore_download_errors = false
  elsif Rails.env.development?
    config.storage = :file
    config.ignore_integrity_errors = false
    config.ignore_processing_errors = false
    config.ignore_download_errors = false
  else
    # config.root = Rails.root.join('tmp')
    # config.cache_dir = "uploads"
    # config.s3_access_policy = :private

    # config.s3_access_key_id = ENV['BCD_S3_KEY']
    # config.s3_secret_access_key = ENV['BCD_S3_SECRET']
    # config.s3_bucket = ENV['BCD_S3_INSTRUCTION_BUCKET']
    config.storage = :fog
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: AmazonConfig.config.access_key,
      aws_secret_access_key: AmazonConfig.config.secret
    }
    # config.fog_directory = AmazonConfig.config.instruction_bucket
    # config.asset_host = 'http://images.brickcitydepot.com'
    config.fog_public = false
    config.cache_dir = "#{Rails.root}/tmp/carrierwave"
    # config.fog_attributes = {'Expires' => 99.years.from_now.httpdate}   I don't even understand what this is all about
  end
end
