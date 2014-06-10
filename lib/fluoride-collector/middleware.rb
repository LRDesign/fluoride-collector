module Fluoride
  module Collector
    class Middleware
      def initialize(app, directory, tagging = nil)
        @app = app
        @directory = directory
        @tagging = tagging
      end

      private

      def thread_locals
        Thread.current[:fluoride_collector] ||= {}
      end

      def storage_path
        thread_locals[collection_type] ||= File::join(@directory, "#{collection_type}-#{Process.pid}-#{Thread.current.object_id}.yml")
      end

      def storage_file
        File::open(storage_path, "a") do |file|
          yield file
        end
      end

      def store(record)
        storage_file do |file|
          file.write(YAML::dump(record))
        end
      end

      def request_hash(env)
        body = nil
        if env['rack.input'].respond_to? :read
          body = env['rack.input'].read
          env['rack.input'].rewind rescue nil
        end
        {
          "content_type" => env['CONTENT_TYPE'],
          "accept" => env["HTTP_ACCEPT_ENCODING"],
          "referer" => env["HTTP_REFERER"],
          "cookies" => env["HTTP_COOKIE"],
          "authorization" => env["HTTP_AUTHORIZATION"],
          "method" => env["REQUEST_METHOD"],
          "host" => env['HTTP_HOST'] || "#{env['SERVER_NAME'] || env['SERVER_ADDR']}:#{env['SERVER_PORT']}",
          "path" => env["SCRIPT_NAME"].to_s + env["PATH_INFO"].to_s,
            "query_string" => env["QUERY_STRING"].to_s,
            "body" => body,
        }
      end

      class CollectExceptions < Middleware
        def call(env)
          @app.call(env)
        rescue Object => ex
          store(
            "type" => "exception_raised",
            "tags" => @tagging,
            "request" => request_hash(env),
            "response" => exception_hash(ex)
          )
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
            store(
              "type" => "normal_exchange",
              "tags" => @tagging,
              "request" => request_hash(env),
              "response" => response_hash(response)
            )
          end
        end

        private

        def collection_type
          :exchange
        end

        def response_hash(response)
          status, headers, body = *response

          {
            "status" => status,
            "headers" => headers,
            "body" => body.to_a.join("") #every body? all of it?
          }
        end
      end
    end
  end
end
