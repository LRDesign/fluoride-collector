require 'railtie-help'

describe Fluoride::Collector::Railtie do
  it "should update the middleware stack" do
    #Ugh :(

    Rails.application.middleware.middlewares.should include(Fluoride::Collector::Middleware)
  end

end
