# frozen_string_literal: true

require_relative 'lib/identisure/version'

Gem::Specification.new do |spec|
  spec.name        = 'identisure-client'
  spec.version     = Identisure::VERSION
  spec.summary     = 'Ruby client for the Identisure REST API'
  spec.description = 'Synchronous Ruby client for Identisure, supporting BankID SE/NO, Freja, MitID, FTN, ' \
                     'Vipps and document upload.'
  spec.authors     = ['Identisure']
  spec.license     = 'MIT'
  spec.homepage    = 'https://github.com/identisure/api-client-ruby'

  spec.required_ruby_version = '>= 3.2.0'

  spec.files = Dir['lib/**/*.rb'] + ['LICENSE', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 2.10'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
