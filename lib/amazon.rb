include AWS::S3
module Amazon
  class Storage

    def self.download(file_name)
      data = S3Object.find(file_name,AmazonConfig.config.instruction_bucket)
      data.value
    end

    def self.authenticated_url(file_name)
      pretty_filename = file_name.match(/\w+\.\w+/).to_s
      S3Object.url_for(file_name,AmazonConfig.config.instruction_bucket,
                       :query => {'response-content-disposition' => "attachment;filename=#{pretty_filename}",
                                  'response-content-type' => 'application/pdf'})
    end

    def self.connect
      AWS::S3::Base.establish_connection!(
        :access_key_id => AmazonConfig.config.access_key,
        :secret_access_key => AmazonConfig.config.secret
      )
    end

    def self.disconnect
      AWS::S3::Base.disconnect!
    end
  end
end
