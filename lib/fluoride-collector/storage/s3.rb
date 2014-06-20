require 'fluoride-collector'
require 'fluoride-collector/storage'
require 'openssl'
require 'base64'

require 'net/http'
require 'net/https'

module Fluoride
  module Collector
    class Storage
      class S3 < Storage
        attr_reader :response
        def write
          http = Net::HTTP.new(host, port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.ca_path = File.expand_path("../../../../certs", __FILE__)
          http.start do
            @response = http.request(put_request)
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

        def base64(data)
          if Base64.respond_to?(:strict_encode64)
            Base64.strict_encode64(data)
          else
            Base64.encode64(data).sub(/\s*\z/m,'')
          end
        end

        def authorization
          hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, access_secret, string_to_sign)
          signature = base64(hmac)

          "AWS #{key_id}:#{signature}"
        end

        def string_to_sign
          "PUT\n#{content_md5}\n#{content_type}\n#{date}\n/#{bucket}/#{remote_path}"
        end

        def content_md5
          @context_md5 ||= base64(OpenSSL::Digest::MD5.digest(record_yaml))
        end

        def content_type
          "text/yaml"
        end

        def date
          @date ||= Time.now.strftime("%a, %d %h %Y %T %z")
        end

        def put_request
          @req ||=
            begin
              req = Net::HTTP::Put.new(uri)
              req["Authorization"] = authorization
              req["Date"] = date
              req["Content-MD5"] = content_md5
              req["Content-Type"] = content_type
              req.body = record_yaml
              req
            end
        end
      end
    end
  end
end
