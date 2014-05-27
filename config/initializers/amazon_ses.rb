ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
                                       :access_key_id => AmazonConfig.config.access_key,
                                       :secret_access_key => AmazonConfig.config.secret