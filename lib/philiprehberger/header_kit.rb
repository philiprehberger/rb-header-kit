# frozen_string_literal: true

require_relative 'header_kit/version'
require_relative 'header_kit/accept'
require_relative 'header_kit/cache_control'
require_relative 'header_kit/content_type'
require_relative 'header_kit/link'
require_relative 'header_kit/negotiation'

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
  end
end
