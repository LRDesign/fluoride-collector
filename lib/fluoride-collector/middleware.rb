require 'uri'
require 'fluoride-collector'
module Fluoride
  module Collector
    class Middleware
      attr_reader :config

      def initialize(app, config)
        @app = app
        @config = config
        @tagging = config.tags
      end

      private

      def store(record)
        #take only pictures
        @config.persister(collection_type, record).write
      rescue Exception => ex
        #leave only footprints
        $stderr.puts "#{ex.inspect}" if $stderr.respond_to? :puts
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
    end
  end
end
