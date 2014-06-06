module Fluoride
  module Collector
    class Railtie < ::Rails::Railtie
      config.fluoride = ActiveSupport::OrderedOptions.new
      config.fluoride.tags = nil
      config.fluoride.directory = "fluoride-collector"

      initializer "fluoride-collector.add_middleware" do |app|
        app.middleware.insert_after("ActionDispatch::ShowExceptions",
                                    Fluoride::Collector::Middleware, config.fluoride.directory, config.fluoride.tags)
      end
    end
  end
end
