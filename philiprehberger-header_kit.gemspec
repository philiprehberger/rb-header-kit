# frozen_string_literal: true

require_relative 'lib/philiprehberger/header_kit/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-header_kit'
  spec.version       = Philiprehberger::HeaderKit::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']
  spec.summary       = 'HTTP header parsing, construction, and content negotiation'
  spec.description   = 'Parse and build Accept, Accept-Language, Accept-Encoding, Authorization, Cache-Control, ' \
                       'Content-Type, Cookie, Link, CORS, Forwarded, and Via HTTP headers. Includes content ' \
                       'negotiation and security header generation.'
  spec.homepage      = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-header_kit'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'
  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = 'https://github.com/philiprehberger/rb-header-kit'
  spec.metadata['changelog_uri']         = 'https://github.com/philiprehberger/rb-header-kit/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/philiprehberger/rb-header-kit/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
