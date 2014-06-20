#!/usr/bin/env ruby
#
require 'fluoride-collector/config'
require 'uri'
require 'yaml'
require 'pp'

yaml_config = YAML::load(File::read(File::expand_path("../test-s3-store.yml", __FILE__)))

config = Fluoride::Collector::Config::S3.new
config.bucket = "lrd-test-fluoride"
config.key_id = yaml_config["key_id"]
config.access_secret = yaml_config["access_secret"]

storage = config.persister("test", {"exclaimation" => "Holy smokes it works!"})
storage.write

puts "Sending:"
puts storage.put_request.body
puts
print "To: "
puts storage.uri
p storage.response
puts
url = URI.parse(storage.uri)

puts "And retrieved:"

get_req = Net::HTTP::Get.new(url.to_s)
http = Net::HTTP.new(url.host, 443)
http.use_ssl = true
http.start do
  puts http.request(get_req)
end
