require 'fluoride-collector'
require 'fluoride-collector/storage'
module Fluoride
  module Collector
    class Storage
      class FS < Storage
        def directory
          @config.directory
        end

        def storage_limit
          @config.storage_limit
        end

        def write
          storage_file do |file|
            file.write(record_yaml)
          end
        end

        def storage_used
          dir = Dir.new(directory)
          dir.inject(0) do |sum, file|
            if file =~ %r{\A\.}
              sum
            else
              sum + File.size(File::join(directory, file))
            end
          end
        end

        def storage_path
          thread_locals[collection_type] ||= File::join(directory, "#{collection_type}-#{Process.pid}-#{Thread.current.object_id}.yml")
        end

        def storage_file
          FileUtils.mkdir_p(File::dirname(storage_path))
          return if storage_used > storage_limit
          File::open(storage_path, "a") do |file|
            yield file
          end
        end
      end
    end
  end
end
