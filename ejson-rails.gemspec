# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ejson/rails/version"

Gem::Specification.new do |spec|
  spec.name          = "ejson-rails"
  spec.version       = EJSON::Rails::VERSION
  spec.authors       = ["Gannon McGibbon"]
  spec.email         = ["gannon.mcgibbon@shopify.com"]

  spec.summary       = "Asymmetric keywise encryption for JSON on Rails"
  spec.description   = "Rails secret management by encrypting values in a JSON hash with a public/private keypair"
  spec.homepage      = "https://github.com/Shopify/ejson-rails"
  spec.license       = "MIT"
  spec.files         = %x(git ls-files -z).split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("ejson")
  spec.add_dependency("railties", ">= 4.1")

  spec.add_development_dependency("rake", "~> 10.0")
  spec.add_development_dependency("rspec", "~> 3.0")
end
