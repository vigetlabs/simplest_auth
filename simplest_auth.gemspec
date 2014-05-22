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

  spec.add_dependency 'bcrypt-ruby', '>= 2.1'
  spec.add_dependency 'i18n'

  spec.add_development_dependency 'bundler'       , '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'activerecord'  , '>= 3.1.0'
  spec.add_development_dependency 'datamapper'    , '>= 1.0.2'
  spec.add_development_dependency 'bson_ext'                   # Avoid warnings when running specs
  spec.add_development_dependency 'mongo_mapper'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'appraisal'

end
