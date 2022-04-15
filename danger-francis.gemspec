# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "francis/gem_version"

Gem::Specification.new do |spec|
  spec.name          = "danger-francis"
  spec.version       = Francis::VERSION
  spec.authors       = ["Marcin Siemaszko"]
  spec.email         = ["marcin.siemaszko@netguru.com"]
  spec.description   = "Plugin that allows reporting data to Francis"
  spec.summary       = "Francis is Netguru internal tool for monitoring technical status of projects. This plugin reports data to our system."
  spec.homepage      = "https://github.com/netguru/danger-francis"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "danger-plugin-api", "~> 1.0"

  # General ruby development
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"

  # Testing support
  spec.add_development_dependency "rspec", "~> 3.4"

  # Linting code and docs
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "yard"

  # Makes testing easy via `bundle exec guard`
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"

  # If you want to work on older builds of ruby
  spec.add_development_dependency "listen", "3.0.7"

  # This gives you the chance to run a REPL inside your tests
  # via:
  #
  #    require 'pry'
  #    binding.pry
  #
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency "pry"
end
