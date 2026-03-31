# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.1] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.3.0] - 2026-03-31

### Added

- `parse_cors` and `build_cors` for CORS header handling
- `security_headers` for generating recommended security headers
- `parse_forwarded` for RFC 7239 Forwarded header parsing
- `parse_via` for Via header parsing

## [0.2.0] - 2026-03-28

### Added

- Parse Accept-Language headers with quality values
- Negotiate best language match from Accept-Language against available languages
- Parse Accept-Encoding headers with quality values
- Parse Authorization headers (Bearer, Basic, Digest schemes)
- Parse Cookie headers into name-value hashes
- Build Set-Cookie header strings with all standard attributes
- Build Accept header strings from structured type arrays

## [0.1.1] - 2026-03-26

### Changed

- Fix README compliance (sponsor badge format, license link)

## [0.1.0] - 2026-03-26

### Added
- Initial release
- Parse Accept headers with quality values and parameters
- Parse and build Cache-Control directives
- Parse Content-Type with charset and boundary
- Parse and build Link headers (RFC 8288)
- Content negotiation matching Accept against available types
