require 'fluoride-collector'

describe Fluoride::Collector::S3Storage do
  let :record do
    {"tagging" => "TEST"}
  end

  let :storage do
    config.persister(:exchange, record)
  end

  let :config do
    Fluoride::Collector::S3Config.new.tap do |cfg|
      cfg.bucket = "test-bucket"
      cfg.key_id = "AKIASOMETHINGSOMETHING"
      cfg.access_secret = "cabbagecabbage"
    end
  end

  it "should sign a reasonable string" do
    expect(storage.string_to_sign).to match %r[\APUT.*]
    expect(storage.string_to_sign).to match %r[.*/test-bucket/exchange(?:-.*){3}.yml\z]
    expect(storage.string_to_sign).to match %r[.*text/yaml.*]
    expect(storage.string_to_sign).to match %r[.*\n[^\n]*,[^\n]*:[^\n]*:[^\n]*\n.*]
    expect(storage.string_to_sign).to match %r[\APUT\n[^\n]+\ntext/yaml\n[^\n]*,[^\n]*:[^\n]*:[^\n]*\n/test-bucket/exchange(?:-.*){3}.yml\z]
  end

  it "should have a consistent index" do
    expect( storage.request_index ).to eq(storage.request_index)

    other_storage = config.persister(:exchange, {"tagging" => "TEST"})
    expect( other_storage.request_index ).to eq(other_storage.request_index)
    expect( storage.request_index ).not_to eq(other_storage.request_index)
  end

  it "should build a reasonable PUT request" do
    expect(storage.put_request["Content-Type"]).to eq("text/yaml")
    expect(YAML.load(storage.put_request.body)).to eq(record)

  end
end
