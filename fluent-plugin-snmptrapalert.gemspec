lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-snmptrapalert"
  spec.version = "0.1.0"
  spec.authors = ["Ajay Ramesh", "Gabe de la Mora"]
  spec.email   = ["ajay.ramesh@microsoft.com", "gadelamo@microsoft.com"]

  spec.summary       = "Input plugin for fluentd to recieve SNMP messages "
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/Azure/fluent-plugin-snmptrapalert"
  spec.license       = "MIT"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = `git ls-files`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.2.10"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
  spec.add_runtime_dependency "snmp", "~> 1.3.2"
end

