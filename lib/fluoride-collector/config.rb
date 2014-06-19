require 'fluoride-collector'
module Fluoride
  module Collector
    class Config
      attr_accessor :tags

      def persister(type, record)
        persister_class.new(self, type, record)
      end

      class FS < Config
        attr_accessor :directory, :storage_limit

        def initialize
          require 'fluoride-collector/storage/fs'
          @storage_limit = 250_000_000
        end

        def persister_class
          Storage::FS
        end
      end

      class S3 < Config
        attr_accessor :bucket, :key_id, :access_secret

        def initialize
          require 'fluoride-collector/storage/s3'
        end

        def persister_class
          Storage::S3
        end
      end
    end
  end
end
