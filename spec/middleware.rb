require 'rack'
require 'fluoride-collector'

describe Fluoride::Collector::Middleware do
  include FileSandbox

  let! :collection_directory do
    dir = sandbox.new(:directory => "collections")
    Dir.new(dir.path)
  end

  let :app do
    run_app = test_app
    klass = middleware_class
    Rack::Builder.app do
      use klass, "collections", "TEST"
      run run_app
    end
  end

  let :env do
    {}
  end

  describe "handling exception" do
    let :test_ex_class do
      Class.new(Exception)
    end

    let :middleware_class do
      Fluoride::Collector::Middleware::CollectExceptions
    end

    let :test_app do
      lambda{|env| raise test_ex_class, "test exception"}
    end

    it "should not change the response" do
      expect{
        app.call(env)
      }.to raise_error
    end

    it "should create a collection file" do
      expect do
        begin
          app.call(env)
        rescue test_ex_class
        end
      end.to change{collection_directory.each.to_a.grep(/[a-z].*/).size}
    end

    it "should keep using the same collection file" do
      begin
        app.call(env)
      rescue test_ex_class
      end

      expect do
        begin
          app.call(env)
        rescue test_ex_class
        end
      end.not_to change{collection_directory.each.to_a.grep(/[a-z].*/).size}
    end

    describe "creates a file" do
      let :yaml do
        begin
          app.call(env)
        rescue test_ex_class
        end
        path = File::join(collection_directory.path, collection_directory.each.to_a.grep(/[a-z].*/).first)
        YAML.load_stream(File.read(path)).first
      end

      it "should have tags" do
        expect(yaml["tags"]).to eq "TEST"
      end
    end
  end

  describe "handling successful responses" do
    let :test_app do
      lambda{|env| response }
    end

    let :response do
      [200, {'Content-Type' => 'text/plain'}, ['Just a test']]
    end

    let :middleware_class do
      Fluoride::Collector::Middleware::CollectExchanges
    end

    it "should not change the response" do
      expect(app.call(env)).to eq response
    end

    it "should create a collection file" do
      expect do
        app.call(env)
      end.to change{collection_directory.each.to_a.grep(/[a-z].*/).size}
    end

    it "should keep using the same collection file" do
      app.call(env)
      expect do
        app.call(env)
      end.not_to change{collection_directory.each.to_a.grep(/[a-z].*/).size}
    end

    describe "creates a file" do
      let :yaml do
        app.call(env)
        path = File::join(collection_directory.path, collection_directory.each.to_a.grep(/[a-z].*/).first)
        YAML.load_stream(File.read(path)).first
      end

      it "should have tags" do
        expect(yaml["tags"]).to eq "TEST"
      end
    end
  end
end
