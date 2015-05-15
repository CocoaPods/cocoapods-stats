# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-stats/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-stats'
  spec.version       = CocoapodsStats::VERSION
  spec.authors       = ['Orta Therox']
  spec.email         = ['orta.therox@gmail.com']
  spec.description   = %q{A short description of cocoapods-stats.}
  spec.summary       = %q{A longer description of cocoapods-stats.}
  spec.homepage      = 'https://github.com/EXAMPLE/cocoapods-stats'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'nap'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
