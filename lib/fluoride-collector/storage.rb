require 'fluoride-collector'
module Fluoride
  module Collector
    class Storage
      attr_reader :collection_type, :record

      def initialize(config, type, record)
        @record = record
        @collection_type = type
        @config = config
      end

      def thread_locals
        Thread.current[:fluoride_collector] ||= {}
      end

      def record_yaml
        @record_yaml ||= YAML::dump(record)
      end
    end
  end
end
