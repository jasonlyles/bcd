# frozen_string_literal: true

include Aws::S3
module Amazon
  class Storage
    def self.authenticated_url(file_name)
      pretty_filename = file_name.match(/\w+\.\w+$/).to_s
      extension = pretty_filename.match(/\w+$/).to_s
      response_content_type = case extension
                              when 'pdf'
                                'application/pdf'
                              when 'html'
                                'text/html'
                              when 'xml'
                                'application/xml'
                              end

      s3_obj = Aws::S3::Object.new(bucket_name: AmazonConfig.config.instruction_bucket, key: file_name)

      s3_obj.presigned_url(
        :get,
        expires_in: 3600,
        response_content_disposition: "attachment;filename=#{pretty_filename}",
        response_content_type: response_content_type
      )
    end
  end
end
