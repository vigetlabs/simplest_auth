# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simplest_auth/version'

Gem::Specification.new do |spec|
  spec.name          = 'simplest_auth'
  spec.version       = SimplestAuth::Version.to_s
  spec.authors       = ['Viget']
  spec.email         = ['developers@viget.com']
  spec.summary       = 'Simple implementation of authentication for Rails'
  spec.homepage      = 'http://github.com/vigetlabs/simplest_auth'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency('bcrypt-ruby', '~> 2.1.1')

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'shoulda'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'activemodel'
end