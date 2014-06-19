require 'fluoride-collector'
require 'fluoride-collector/storage'
require 'net/http'
require 'openssl'
require 'base64'
module Fluoride
  module Collector
    class Storage
      class S3 < Storage
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
    end
  end
end
