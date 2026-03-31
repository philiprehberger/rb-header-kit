# frozen_string_literal: true

require_relative 'header_kit/version'
require_relative 'header_kit/accept'
require_relative 'header_kit/accept_builder'
require_relative 'header_kit/accept_encoding'
require_relative 'header_kit/accept_language'
require_relative 'header_kit/authorization'
require_relative 'header_kit/cache_control'
require_relative 'header_kit/content_type'
require_relative 'header_kit/cookie'
require_relative 'header_kit/link'
require_relative 'header_kit/negotiation'
require_relative 'header_kit/cors'
require_relative 'header_kit/security'
require_relative 'header_kit/forwarded'

module Philiprehberger
  module HeaderKit
    class Error < StandardError; end

    # Parse an Accept header into structured entries sorted by quality.
    #
    # @param header [String] the Accept header value
    # @return [Array<Hash>] entries with :type, :quality, :params keys
    def self.parse_accept(header)
      Accept.parse(header)
    end

    # Build an Accept header string from an array of type hashes.
    #
    # @param types [Array<Hash>] each with :type and optional :quality
    # @return [String] formatted Accept header value
    def self.build_accept(types)
      AcceptBuilder.build(types)
    end

    # Parse an Accept-Encoding header into structured entries sorted by quality.
    #
    # @param header [String] the Accept-Encoding header value
    # @return [Array<Hash>] entries with :encoding, :quality keys
    def self.parse_accept_encoding(header)
      AcceptEncoding.parse(header)
    end

    # Parse an Accept-Language header into structured entries sorted by quality.
    #
    # @param header [String] the Accept-Language header value
    # @return [Array<Hash>] entries with :language, :quality keys
    def self.parse_accept_language(header)
      AcceptLanguage.parse(header)
    end

    # Negotiate the best language from an Accept-Language header.
    #
    # @param header [String] the Accept-Language header value
    # @param available [Array<String>] list of available language tags
    # @return [String, nil] the best matching language, or nil if no match
    def self.negotiate_language(header, available)
      AcceptLanguage.negotiate(header, available)
    end

    # Parse an Authorization header into its components.
    #
    # @param header [String] the Authorization header value
    # @return [Hash] with :scheme and :credentials or :params
    def self.parse_authorization(header)
      Authorization.parse(header)
    end

    # Parse a Cache-Control header into a directive hash.
    #
    # @param header [String] the Cache-Control header value
    # @return [Hash{Symbol => true, Integer, String}] parsed directives
    def self.parse_cache_control(header)
      CacheControl.parse(header)
    end

    # Build a Cache-Control header string from a directive hash.
    #
    # @param directives [Hash{Symbol => true, Integer, String}] directive hash
    # @return [String] formatted Cache-Control header value
    def self.build_cache_control(directives)
      CacheControl.build(directives)
    end

    # Parse a Content-Type header into its components.
    #
    # @param header [String] the Content-Type header value
    # @return [Hash] with :media_type, :charset, :boundary keys
    def self.parse_content_type(header)
      ContentType.parse(header)
    end

    # Parse a Cookie header into a name-value hash.
    #
    # @param header [String] the Cookie header value
    # @return [Hash{String => String}] cookie name-value pairs
    def self.parse_cookie(header)
      Cookie.parse(header)
    end

    # Build a Set-Cookie header string.
    #
    # @param name [String] cookie name
    # @param value [String] cookie value
    # @param options [Hash] optional attributes (expires:, max_age:, secure:, httponly:, samesite:, path:, domain:)
    # @return [String] formatted Set-Cookie header value
    def self.build_set_cookie(name, value, **options)
      Cookie.build_set_cookie(name, value, **options)
    end

    # Parse a Link header into an array of link entries.
    #
    # @param header [String] the Link header value
    # @return [Array<Hash>] entries with :uri, :rel, :type, :title keys
    def self.parse_link(header)
      Link.parse(header)
    end

    # Build a Link header string from an array of link hashes.
    #
    # @param links [Array<Hash>] each with :uri and optional :rel, :type, :title
    # @return [String] formatted Link header value
    def self.build_link(links)
      Link.build(links)
    end

    # Find the best matching media type via content negotiation.
    #
    # @param accept_header [String] the Accept header value
    # @param available [Array<String>] list of available media types
    # @return [String, nil] the best matching type, or nil if no match
    def self.negotiate(accept_header, available)
      Negotiation.negotiate(accept_header, available)
    end

    # Parse CORS-related headers from a request.
    #
    # @param headers [Hash] request headers hash
    # @return [Hash] with :origin, :method, :headers keys
    def self.parse_cors(headers)
      Cors.parse(headers)
    end

    # Build CORS response headers.
    #
    # @param options [Hash] CORS options (origin:, methods:, headers:, max_age:, credentials:, expose:)
    # @return [Hash{String => String}] response headers
    def self.build_cors(**options)
      Cors.build(**options)
    end

    # Generate recommended security response headers.
    #
    # @param options [Hash] overrides (hsts:, csp:, frame:, content_type_options:, referrer_policy:)
    # @return [Hash{String => String}] security headers
    def self.security_headers(**options)
      Security.headers(**options)
    end

    # Parse an RFC 7239 Forwarded header.
    #
    # @param header [String] the Forwarded header value
    # @return [Array<Hash>] parsed entries with symbol keys
    def self.parse_forwarded(header)
      Forwarded.parse(header)
    end

    # Parse a Via header into structured entries.
    #
    # @param header [String] the Via header value
    # @return [Array<Hash>] entries with :protocol, :host, :comment keys
    def self.parse_via(header)
      Forwarded.parse_via(header)
    end
  end
end
