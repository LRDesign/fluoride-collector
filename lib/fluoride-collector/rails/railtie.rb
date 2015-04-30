require 'fluoride-collector'

module Fluoride
  module Collector
    class Railtie < ::Rails::Railtie
      config.fluoride = ActiveSupport::OrderedOptions.new
      config.fluoride.storage_limit = 250_000_000
      config.fluoride.tags = nil
      config.fluoride.directory = "fluoride/recorded-requests"
      config.fluoride.store_to = :file

      initializer "fluoride-collector.add_middleware" do |app|
        cfg = nil
        case config.fluoride.store_to
        when :file
          cfg = Fluoride::Collector::Config::FS.new
          cfg.directory = config.fluoride.directory
          cfg.storage_limit = config.fluoride.storage_limit
        when :s3
          cfg = Fluoride::Collector::Config::S3.new
          cfg.bucket = config.fluoride.bucket
          cfg.key_id = config.fluoride.key_id
          cfg.access_secret = config.fluoride.access_secret
        else
          raise Fluoride::Collector::ConfigurationError, "Don't know how to store to #{config.fluoride.store_to}!"
        end
        cfg.tags = config.fluoride.tags

        app.middleware.use(Fluoride::Collector::Middleware::CollectExceptions, cfg)
        app.middleware.insert(0, Fluoride::Collector::Middleware::CollectExchanges, cfg)
      end
    end
  end
end
