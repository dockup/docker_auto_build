# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docker_auto_build/version'

Gem::Specification.new do |spec|
  spec.name          = "docker_auto_build"
  spec.version       = DockerAutoBuild::VERSION
  spec.authors       = ["Emil Soman"]
  spec.email         = ["emil@codemancers.com"]

  spec.summary       = %q{A simple app that builds and pushes docker images}
  spec.description   = %q{A simple app that builds and pushes docker images}
  spec.homepage      = "https://github.com/code-mancers/docker_auto_build"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra", "~> 1.4"
  spec.add_dependency "sucker_punch", "~> 1.5"
  spec.add_dependency "httparty", "~> 0.13"
end
