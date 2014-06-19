ENV["RAILS_ENV"] ||= 'test'

# Only the parts of rails we want to use
# if you want everything, use "rails/all"
require "action_controller/railtie"
require "rails/test_unit/railtie"
require 'fluoride-collector/rails'

#root = File.expand_path(File.dirname(__FILE__))

# Define the application and configuration
module Fixture
  class Application < ::Rails::Application
    # configuration here if needed
    config.active_support.deprecation = :stderr
    config.eager_load = false
  end
end

p Rails.configuration.middleware
# Initialize the application
Fixture::Application.initialize!

RSpec.configure do |config|
end
