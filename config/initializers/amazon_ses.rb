creds = Aws::Credentials.new(AmazonConfig.config.access_key, AmazonConfig.config.secret)
Aws::Rails.add_action_mailer_delivery_method(:aws_sdk, credentials: creds, region: 'us-east-1')