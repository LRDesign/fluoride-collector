module Fluoride
  module Collector
    class Railtie < ::Rails::Railtie
      config.fluoride = ActiveSupport::OrderedOptions.new
      config.fluoride.storage_limit = 250_000_000
      config.fluoride.tags = nil
      config.fluoride.directory = "fluoride-collector"

      initializer "fluoride-collector.add_middleware" do |app|
        cfg = Fluoride::Collector::Config.new

        cfg.directory = config.fluoride.directory
        cfg.storage_limit = config.fluoride.storage_limit
        cfg.tags = config.fluoride.tags

        app.middleware.use(Fluoride::Collector::Middleware::CollectExceptions, cfg)
        app.middleware.insert(0, Fluoride::Collector::Middleware::CollectExchanges, cfg)
      end
    end
  end
end
