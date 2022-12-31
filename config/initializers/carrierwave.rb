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

    # config.s3_access_key_id = Rails.application.credentials.aws.access_key_id
    # config.s3_secret_access_key = Rails.application.credentials.aws.secret_access_key
    # config.s3_bucket = Rails.application.credentials.aws.instruction_bucket
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
