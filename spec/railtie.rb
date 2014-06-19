require "action_controller/railtie"
require "rails/test_unit/railtie"
require 'fluoride-collector/rails'

describe Fluoride::Collector::Railtie do

  ENV["RAILS_ENV"] ||= 'test'

  def config(app)

  end

  let :rails_application do
    Class.new(::Rails::Application) do
      config.active_support.deprecation = :stderr
      config.eager_load = false
    end.tap do |app|
      config(app)
      app.initialize!
    end
  end

  after :each do
    Rails.application = nil #because Rails has ideas of it's own, silly thing
  end

  it "should add exception collection to the middleware stack" do
    expect(rails_application.middleware.middlewares).to include(Fluoride::Collector::Middleware::CollectExceptions)
  end

  it "should add exchange collection to the middleware stack" do
    expect(rails_application.middleware.middlewares).to include(Fluoride::Collector::Middleware::CollectExchanges)
  end

  it "should put exchange collection at top of stack" do
    expect(rails_application.middleware.middlewares.first).to eq(Fluoride::Collector::Middleware::CollectExchanges)
  end

  describe "configured to use S3" do
    def config(app)
      app.configure do
        config.fluoride.store_to = :s3
        config.fluoride.bucket = "nowhere-really"
        config.fluoride.key_id = "testtest"
        config.fluoride.access_secrety = "donttellnobody"
      end
    end

    it "should put exchange collection at top of stack" do
      expect(rails_application.middleware.middlewares.first).to eq(Fluoride::Collector::Middleware::CollectExchanges)
    end

    it "should configured collector with S3Storage" do
      collector = rails_application.middleware.middlewares.first.build(proc{})
      expect(collector.config.persister("exchange", {})).to be_a(Fluoride::Collector::Storage::S3)
    end
  end
end
