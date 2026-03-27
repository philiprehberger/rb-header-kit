# philiprehberger-header_kit

[![Tests](https://github.com/philiprehberger/rb-header-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-header-kit/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-header_kit.svg)](https://rubygems.org/gems/philiprehberger-header_kit)
[![License](https://img.shields.io/github/license/philiprehberger/rb-header-kit)](LICENSE)
[![Sponsor](https://img.shields.io/badge/sponsor-philiprehberger-pink?logo=githubsponsors)](https://github.com/sponsors/philiprehberger)

HTTP header parsing, construction, and content negotiation

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-header_kit"
```

Or install directly:

```bash
gem install philiprehberger-header_kit
```

## Usage

```ruby
require "philiprehberger/header_kit"
```

### Parse Accept

```ruby
Philiprehberger::HeaderKit.parse_accept("text/html;q=0.9, application/json")
# => [{type: "application/json", quality: 1.0, params: {}},
#     {type: "text/html", quality: 0.9, params: {}}]
```

### Parse Cache-Control

```ruby
Philiprehberger::HeaderKit.parse_cache_control("public, max-age=3600, must-revalidate")
# => {public: true, max_age: 3600, must_revalidate: true}
```

### Build Cache-Control

```ruby
Philiprehberger::HeaderKit.build_cache_control(public: true, max_age: 3600)
# => "public, max-age=3600"
```

### Parse Content-Type

```ruby
Philiprehberger::HeaderKit.parse_content_type("text/html; charset=utf-8")
# => {media_type: "text/html", charset: "utf-8", boundary: nil}
```

### Parse Link

```ruby
Philiprehberger::HeaderKit.parse_link('<https://example.com/2>; rel="next"')
# => [{uri: "https://example.com/2", rel: "next", type: nil, title: nil}]
```

### Build Link

```ruby
Philiprehberger::HeaderKit.build_link([{uri: "https://example.com/2", rel: "next"}])
# => '<https://example.com/2>; rel="next"'
```

### Content Negotiation

```ruby
Philiprehberger::HeaderKit.negotiate("text/html;q=0.9, application/json", ["text/html", "application/json"])
# => "application/json"
```

## API

| Method | Description |
|--------|-------------|
| `HeaderKit.parse_accept(header)` | Parse Accept header into sorted entries |
| `HeaderKit.parse_cache_control(header)` | Parse Cache-Control into directive hash |
| `HeaderKit.build_cache_control(directives)` | Build Cache-Control string from hash |
| `HeaderKit.parse_content_type(header)` | Parse Content-Type into components |
| `HeaderKit.parse_link(header)` | Parse Link header into entry array |
| `HeaderKit.build_link(links)` | Build Link header from array of hashes |
| `HeaderKit.negotiate(accept_header, available)` | Content negotiation, returns best match or nil |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
