# frozen_string_literal: true

require_relative 'lib/idkollen/version'

Gem::Specification.new do |spec|
  spec.name        = 'idkollen-client'
  spec.version     = Idkollen::VERSION
  spec.summary     = 'Ruby client for the IDkollen REST API'
  spec.description = 'Synchronous Ruby client for IDkollen, supporting BankID SE/NO, Freja, MitID, FTN, Vipps and document upload.'
  spec.authors     = ['IDkollen']
  spec.license     = 'MIT'
  spec.homepage    = 'https://github.com/idkollen/idk-clients'

  spec.required_ruby_version = '>= 3.2.0'

  spec.files = Dir['lib/**/*.rb'] + ['README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 2.10'
  spec.add_dependency 'faraday-multipart', '~> 1.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
