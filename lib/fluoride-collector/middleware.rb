require 'uri'

module Fluoride
  module Collector
    class Config
      attr_accessor :tags

      def persister(type, record)
        persister_class.new(self, type, record)
      end
    end

    class FSConfig < Config
      attr_accessor :directory, :storage_limit

      def initialize
        @storage_limit = 250_000_000
      end

      def persister_class
        FSStorage
      end
    end



    class S3Config < Config
      attr_accessor :bucket, :key_id, :access_secret

      def initialize
        require 'net/http'
        require 'openssl'
        require 'base64'
      end

      def persister_class
        S3Storage
      end
    end

    class Storage
      attr_reader :collection_type, :record

      def initialize(config, type, record)
        @record = record
        @collection_type = type
        @config = config
      end

      def thread_locals
        Thread.current[:fluoride_collector] ||= {}
      end

      def record_yaml
        @record_yaml ||= YAML::dump(record)
      end
    end

    class S3Storage < Storage
      def write
        Net::HTTP.start(host, port) do |http|
          res = http.request(put_request)
        end
      end

      def bucket
        @config.bucket
      end

      def key_id
        @config.key_id
      end

      def access_secret
        @config.access_secret
      end

      def host
        "#{bucket}.s3.amazonaws.com"
      end

      def port
        443
      end

      def request_index
        @request_index ||=
          begin
            thread_locals[:request_index] ||= 0
            thread_locals[:request_index] += 1
          end
      end

      def remote_path
        @remote_path ||= "#{collection_type}-#{Process.pid}-#{Thread.current.object_id}-#{request_index}.yml"
      end

      def uri
        "https://#{host}/#{remote_path}"
      end

      def authorization
        hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, string_to_sign, access_secret)
        signature = Base64.strict_encode64(hmac)

        "AWS #{key_id}:#{signature}"
      end

      def string_to_sign
        "PUT\n#{content_md5}\n#{content_type}\n#{date}\n/#{bucket}/#{remote_path}"
      end

      def content_md5
        @context_md5 ||= Base64.strict_encode64(OpenSSL::Digest::MD5.digest(record_yaml))
      end

      def content_type
        "text/yaml"
      end

      def date
        @date ||= Time.now.strftime("+%a, %d %h %Y %T %z")
      end

      def put_request
        req = Net::HTTP::Put.new(uri)
        req["Authorization"] = authorization
        req["Date"] = date
        req["Content-MD5"] = content_md5
        req["Content-Type"] = content_type
        req.body = record_yaml
        return req
      end
    end

    class FSStorage < Storage
      def directory
        @config.directory
      end

      def storage_limit
        @config.storage_limit
      end

      def write
        storage_file do |file|
          file.write(record_yaml)
        end
      end

      def storage_used
        dir = Dir.new(directory)
        dir.inject(0) do |sum, file|
          if file =~ %r{\A\.}
            sum
          else
            sum + File.size(File::join(directory, file))
          end
        end
      end

      def storage_path
        thread_locals[collection_type] ||= File::join(directory, "#{collection_type}-#{Process.pid}-#{Thread.current.object_id}.yml")
      end

      def storage_file
        FileUtils.mkdir_p(File::dirname(storage_path))
        return if storage_used > storage_limit
        File::open(storage_path, "a") do |file|
          yield file
        end
      end
    end

    class Middleware
      def initialize(app, config)
        @app = app
        @config = config
        @tagging = config.tags
      end

      private

      def store(record)
        @config.persister(collection_type, record).write
      end

      def clean_hash(hash)
        hash.each_key do |key|
          value = hash[key]
          case value
          when String
            if value.respond_to?(:ascii_only?) and value.ascii_only? and value.respond_to?(:force_encoding)
              value = value.dup
              value.force_encoding("US-ASCII")
              hash[key] = value
            end
          when Hash
            hash[key] = clean_hash(value)
          end
        end
        hash
      end

      def request_hash(env)
        body = nil
        if env['rack.input'].respond_to? :read
          body = env['rack.input'].read
          env['rack.input'].rewind rescue nil
        end
        clean_hash(
          "content_type" => env['CONTENT_TYPE'],
          "accept" => env["HTTP_ACCEPT_ENCODING"],
          "referer" => env["HTTP_REFERER"],
          "cookies" => env["HTTP_COOKIE"],
          "authorization" => env["HTTP_AUTHORIZATION"],
          "method" => env["REQUEST_METHOD"],
          "host" => env['HTTP_HOST'] || "#{env['SERVER_NAME'] || env['SERVER_ADDR']}:#{env['SERVER_PORT']}",
          "path" => URI.unescape(env["SCRIPT_NAME"].to_s + env["PATH_INFO"].to_s),
          "query_string" => env["QUERY_STRING"].to_s,
          "body" => body
        )
      end

      class CollectExceptions < Middleware
        def call(env)
          @app.call(env)
        rescue Object => ex
          store( clean_hash(
              "type" => "exception_raised",
              "tags" => @tagging,
              "request" => request_hash(env),
              "response" => exception_hash(ex)
          ))
          raise
        end

        private

        def collection_type
          :exception
        end

        def exception_hash(ex)
          {
            "type" => ex.class.name,
            "message" => ex.message,
            "backtrace" => ex.backtrace[0..10]
          }
        end
      end

      class CollectExchanges < Middleware
        def call(env)
          @app.call(env).tap do |response|
            store( clean_hash(
              "type" => "normal_exchange",
              "tags" => @tagging,
              "request" => request_hash(env),
              "response" => response_hash(response)
            ))
          end
        end

        private

        def collection_type
          :exchange
        end

        def extract_body(body)
          array = []
          body.each do |chunk|
            array << chunk
          end
          body.rewind if body.respond_to?(:rewind)
          array
        end

        def response_hash(response)
          status, headers, body = *response

          {
            "status" => status,
            "headers" => headers.to_hash,
            "body" => extract_body(body)
          }
        end
      end
    end
  end
end
