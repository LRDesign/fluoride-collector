require 'rspec'
require 'rspec/core/formatters/base_formatter'
require 'cadre/rspec'
require 'file-sandbox'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.add_formatter(Cadre::RSpec::NotifyOnCompleteFormatter)
  config.add_formatter(Cadre::RSpec::QuickfixFormatter)
end
