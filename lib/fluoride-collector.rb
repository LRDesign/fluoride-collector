module Fluoride
  module Collector
    class ConfigurationError < ::StandardError
    end
  end
end

require 'fluoride-collector/config'
require 'fluoride-collector/middleware/collect-exceptions'
require 'fluoride-collector/middleware/collect-exchanges'
require 'fluoride-collector/rails' if defined?(Rails)
