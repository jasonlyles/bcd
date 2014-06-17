module AWS
  module S3
    class S3Object
      #Pulled this from the latest. It's not part of an official release yet.
      def self.path!(bucket, name, options = {}) #:nodoc:
        # We're using the second argument for options
        if bucket.is_a?(Hash)
          options.replace(bucket)
          bucket = nil
        end
        path = '/' << File.join(bucket_name(bucket), name)
        if (query = options[:query]).respond_to?(:to_query_string)
          path << query.to_query_string
        end
        path
      end
    end
  end
end