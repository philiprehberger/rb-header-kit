# philiprehberger-header_kit

[![Tests](https://github.com/philiprehberger/rb-header-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-header-kit/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-header_kit.svg)](https://rubygems.org/gems/philiprehberger-header_kit)
[![GitHub release](https://img.shields.io/github/v/release/philiprehberger/rb-header-kit)](https://github.com/philiprehberger/rb-header-kit/releases)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-header-kit)](https://github.com/philiprehberger/rb-header-kit/commits/main)
[![License](https://img.shields.io/github/license/philiprehberger/rb-header-kit)](LICENSE)
[![Bug Reports](https://img.shields.io/github/issues/philiprehberger/rb-header-kit/bug)](https://github.com/philiprehberger/rb-header-kit/issues?q=is%3Aissue+is%3Aopen+label%3Abug)
[![Feature Requests](https://img.shields.io/github/issues/philiprehberger/rb-header-kit/enhancement)](https://github.com/philiprehberger/rb-header-kit/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ec6cb9)](https://github.com/sponsors/philiprehberger)

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

### Build Accept

```ruby
Philiprehberger::HeaderKit.build_accept([{type: "text/html"}, {type: "application/json", quality: 0.9}])
# => "text/html, application/json;q=0.9"
```

### Parse Accept-Language

```ruby
Philiprehberger::HeaderKit.parse_accept_language("en-US,en;q=0.9,fr;q=0.8")
# => [{language: "en-US", quality: 1.0}, {language: "en", quality: 0.9}, {language: "fr", quality: 0.8}]
```

### Negotiate Language

```ruby
Philiprehberger::HeaderKit.negotiate_language("en-US,fr;q=0.9", ["fr", "en"])
# => "en"
```

### Parse Accept-Encoding

```ruby
Philiprehberger::HeaderKit.parse_accept_encoding("gzip, deflate;q=0.5, br;q=0.8")
# => [{encoding: "gzip", quality: 1.0}, {encoding: "br", quality: 0.8}, {encoding: "deflate", quality: 0.5}]
```

### Parse Authorization

```ruby
Philiprehberger::HeaderKit.parse_authorization("Bearer eyJhbGciOiJIUzI1NiJ9")
# => {scheme: "Bearer", credentials: "eyJhbGciOiJIUzI1NiJ9"}

Philiprehberger::HeaderKit.parse_authorization('Digest username="admin", realm="example"')
# => {scheme: "Digest", params: {"username" => "admin", "realm" => "example"}}
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

### Parse Cookie

```ruby
Philiprehberger::HeaderKit.parse_cookie("session=abc123; user=john")
# => {"session" => "abc123", "user" => "john"}
```

### Build Set-Cookie

```ruby
Philiprehberger::HeaderKit.build_set_cookie("session", "abc123", secure: true, httponly: true, path: "/")
# => "session=abc123; Path=/; Secure; HttpOnly"
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

### Parse CORS

```ruby
headers = {
  'Origin' => 'https://example.com',
  'Access-Control-Request-Method' => 'POST',
  'Access-Control-Request-Headers' => 'Content-Type, Authorization'
}
Philiprehberger::HeaderKit.parse_cors(headers)
# => {origin: "https://example.com", method: "POST", headers: ["Content-Type", "Authorization"]}
```

### Build CORS

```ruby
Philiprehberger::HeaderKit.build_cors(
  origin: "https://example.com",
  methods: ["GET", "POST"],
  headers: ["Content-Type"],
  max_age: 3600,
  credentials: true
)
# => {"Access-Control-Allow-Origin" => "https://example.com", ...}
```

### Security Headers

```ruby
Philiprehberger::HeaderKit.security_headers
# => {"X-Content-Type-Options" => "nosniff", "X-Frame-Options" => "DENY", ...}

Philiprehberger::HeaderKit.security_headers(hsts: "max-age=31536000", csp: "default-src 'self'")
# => includes Strict-Transport-Security and Content-Security-Policy
```

### Parse Forwarded

```ruby
Philiprehberger::HeaderKit.parse_forwarded('for=192.0.2.60;proto=http;by=203.0.113.43')
# => [{for: "192.0.2.60", proto: "http", by: "203.0.113.43"}]
```

### Parse Via

```ruby
Philiprehberger::HeaderKit.parse_via('1.1 vegur, 1.0 fred')
# => [{protocol: "1.1", host: "vegur"}, {protocol: "1.0", host: "fred"}]
```

## API

| Method | Description |
|--------|-------------|
| `HeaderKit.parse_accept(header)` | Parse Accept header into sorted entries |
| `HeaderKit.build_accept(types)` | Build Accept header string from type array |
| `HeaderKit.parse_accept_language(header)` | Parse Accept-Language into sorted entries |
| `HeaderKit.negotiate_language(header, available)` | Language negotiation, returns best match or nil |
| `HeaderKit.parse_accept_encoding(header)` | Parse Accept-Encoding into sorted entries |
| `HeaderKit.parse_authorization(header)` | Parse Authorization header (Bearer, Basic, Digest) |
| `HeaderKit.parse_cache_control(header)` | Parse Cache-Control into directive hash |
| `HeaderKit.build_cache_control(directives)` | Build Cache-Control string from hash |
| `HeaderKit.parse_content_type(header)` | Parse Content-Type into components |
| `HeaderKit.parse_cookie(header)` | Parse Cookie header into name-value hash |
| `HeaderKit.build_set_cookie(name, value, **opts)` | Build Set-Cookie header string |
| `HeaderKit.parse_link(header)` | Parse Link header into entry array |
| `HeaderKit.build_link(links)` | Build Link header from array of hashes |
| `HeaderKit.negotiate(accept_header, available)` | Content negotiation, returns best match or nil |
| `HeaderKit.parse_cors(headers)` | Parse CORS-related request headers |
| `HeaderKit.build_cors(**options)` | Build CORS response headers |
| `HeaderKit.security_headers(**options)` | Generate recommended security headers |
| `HeaderKit.parse_forwarded(header)` | Parse RFC 7239 Forwarded header |
| `HeaderKit.parse_via(header)` | Parse Via header into structured entries |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this package useful, consider giving it a star on GitHub — it helps motivate continued maintenance and development.

[![LinkedIn](https://img.shields.io/badge/Philip%20Rehberger-LinkedIn-0A66C2?logo=linkedin)](https://www.linkedin.com/in/philiprehberger)
[![More packages](https://img.shields.io/badge/more-open%20source%20packages-blue)](https://philiprehberger.com/open-source-packages)

## License

[MIT](LICENSE)
