require 'rspec'
require 'rspec/core/formatters/base_formatter'
require 'file-sandbox'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
end
