module Fluoride
  module Collector
    class Railtie < ::Rails::Railtie
      config.fluoride = ActiveSupport::OrderedOptions.new
      config.fluoride.tags = nil
      config.fluoride.directory = "fluoride-collector"

      initializer "fluoride-collector.add_middleware" do |app|
        app.middleware.use(Fluoride::Collector::Middleware::CollectExceptions, config.fluoride.directory, config.fluoride.tags)
        app.middleware.insert("Rack::Sendfile",
                              Fluoride::Collector::Middleware::CollectExchanges,
                              config.fluoride.directory, config.fluoride.tags)
      end
    end
  end
end
