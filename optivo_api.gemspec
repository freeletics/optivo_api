lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "optivo_api/version"

Gem::Specification.new do |spec|
  spec.name          = "optivo_api"
  spec.version       = OptivoApi::VERSION
  spec.authors       = ["Michael Deimel"]
  spec.email         = ["michael.deimel@freeletics.com"]

  spec.summary       = "A wrapper for Optivo SOAP API"
  spec.description   = "A wrapper for Optivo SOAP API"
  spec.homepage      = "https://github.com/freeletics/optivo_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "savon", "~> 2.11"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", ">= 1.10"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec"
end
