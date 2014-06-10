require 'railtie-help'

describe Fluoride::Collector::Railtie do
  it "should add exception collection to the middleware stack" do
    expect(Rails.application.middleware.middlewares).to include(Fluoride::Collector::Middleware::CollectExceptions)
  end

  it "should add exchange collection to the middleware stack" do
    expect(Rails.application.middleware.middlewares).to include(Fluoride::Collector::Middleware::CollectExchanges)
  end

  it "should put exchange collection at top of stack" do
    expect(Rails.application.middleware.middlewares.first).to eq(Fluoride::Collector::Middleware::CollectExchanges)
  end
end
