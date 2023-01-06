require "#{Rails.root}/lib/config/amazon_config.rb"

AmazonConfig.configure do |config|
  config.instruction_bucket = Rails.application.credentials.aws.instruction_bucket
  config.image_bucket = Rails.application.credentials.aws.image_bucket
  config.asset_bucket = Rails.application.credentials.aws.asset_bucket
  config.access_key = Rails.application.credentials.aws.access_key_id
  config.secret = Rails.application.credentials.aws.secret_access_key
end

Aws.config.update({
                    region: 'us-east-1',
                    credentials: Aws::Credentials.new(Rails.application.credentials.aws.access_key_id, Rails.application.credentials.aws.secret_access_key)
                  })
