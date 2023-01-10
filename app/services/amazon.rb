# frozen_string_literal: true

module Amazon
  class Storage
    include Aws::S3

    def self.authenticated_url(file_name)
      pretty_filename = file_name.match(/\w+\.\w+$/).to_s
      extension = pretty_filename.match(/\w+$/).to_s
      response_content_types = {
        'pdf' => 'application/pdf',
        'html' => 'text/html',
        'xml' => 'application/xml'
      }

      s3_obj = Aws::S3::Object.new(bucket_name: AmazonConfig.config.instruction_bucket, key: file_name)

      s3_obj.presigned_url(
        :get,
        expires_in: 3600,
        response_content_disposition: "attachment;filename=#{pretty_filename}",
        response_content_type: response_content_types[extension]
      )
    end
  end
end
