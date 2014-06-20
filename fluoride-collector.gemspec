Gem::Specification.new do |spec|
  spec.name		= "fluoride-collector"
  spec.version		= "0.0.6"
  author_list = {
    "Judson Lester" => 'nyarly@gmail.com',
    "Evan Down" => 'evan@lrdesign.com'
  }
  spec.authors		= author_list.keys
  spec.email		= spec.authors.map {|name| author_list[name]}
  spec.summary		= "Middleware to collect request and reponse pairs"
  spec.description	= <<-EndDescription
  Part of the Fluoride suite - tools for making your black box a bit whiter
  EndDescription

  spec.homepage        = "http://nyarly.github.com/#{spec.name.downcase}"
  spec.required_rubygems_version = Gem::Requirement.new(">= 0") if spec.respond_to? :required_rubygems_version=

  # Do this: y$@"
  # !!find lib bin doc spec spec_help -not -regex '.*\.sw.' -type f 2>/dev/null
  spec.files		= %w[
    lib/fluoride-collector/rails/railtie.rb
    lib/fluoride-collector/config.rb
    lib/fluoride-collector/middleware/collect-exchanges.rb
    lib/fluoride-collector/middleware/collect-exceptions.rb
    lib/fluoride-collector/rails.rb
    lib/fluoride-collector/storage/fs.rb
    lib/fluoride-collector/storage/s3.rb
    lib/fluoride-collector/storage.rb
    lib/fluoride-collector/middleware.rb
    lib/fluoride-collector.rb

    spec/railtie.rb
    spec/middleware.rb
    spec_help/spec_helper.rb
    spec_help/gem_test_suite.rb
    spec_help/railtie-help.rb
    spec_help/file-sandbox.rb

    certs/1ec4d31a.0
    certs/c01cdfa2.0
    certs/bad35b78.0
    certs/6faac4e3.0
    certs/7d0b38bd.0
    certs/ee1365c0.0
    certs/24ad0b63.0
    certs/b204d74a.0
    certs/dc45b0bd.0
    certs/cb357862.0
    certs/b8e83700.0
    certs/0f11b315.0
    certs/c0ff1f52.0
    certs/415660c1.0
  ]

  spec.test_file        = "spec_help/gem_test_suite.rb"
  spec.licenses = ["MIT"]
  spec.require_paths = %w[lib/]
  spec.rubygems_version = "1.3.5"

  spec.has_rdoc		= true
  spec.extra_rdoc_files = Dir.glob("doc/**/*")
  spec.rdoc_options	= %w{--inline-source }
  spec.rdoc_options	+= %w{--main doc/README }
  spec.rdoc_options	+= ["--title", "#{spec.name}-#{spec.version} Documentation"]

  #spec.add_dependency("", "> 0")

  #spec.post_install_message = "Thanks for installing my gem!"
end
