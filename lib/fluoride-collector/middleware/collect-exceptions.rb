require 'fluoride-collector/middleware'
module Fluoride
  module Collector
    class Middleware
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
    end
  end
end
