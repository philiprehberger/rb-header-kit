# frozen_string_literal: true

require_relative 'lib/philiprehberger/header_kit/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-header_kit'
  spec.version       = Philiprehberger::HeaderKit::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']
  spec.summary       = 'HTTP header parsing, construction, and content negotiation'
  spec.description   = 'Parse and build Accept, Accept-Language, Accept-Encoding, Authorization, Cache-Control, ' \
                       'Content-Type, Cookie, and Link HTTP headers. Includes content negotiation for selecting ' \
                       'the best response type or language.'
  spec.homepage      = 'https://github.com/philiprehberger/rb-header-kit'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'
  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['changelog_uri']         = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']       = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
