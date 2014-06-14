module Fluoride
  module Collector
    class Railtie < ::Rails::Railtie
      config.fluoride = ActiveSupport::OrderedOptions.new
      config.fluoride.storage_limit = 250_000_000
      config.fluoride.tags = nil
      config.fluoride.directory = "fluoride-collector"

      initializer "fluoride-collector.add_middleware" do |app|
        app.middleware.use(   Fluoride::Collector::Middleware::CollectExceptions,
                              config.fluoride.directory,
                              config.fluoride.storage_limit,
                              config.fluoride.tags)
        app.middleware.insert("Rack::Sendfile",
                              Fluoride::Collector::Middleware::CollectExchanges,
                              config.fluoride.directory,
                              config.fluoride.storage_limit,
                              config.fluoride.tags)
      end
    end
  end
end
