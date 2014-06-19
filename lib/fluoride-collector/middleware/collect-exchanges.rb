require 'fluoride-collector/middleware'
module Fluoride
  module Collector
    class Middleware
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
