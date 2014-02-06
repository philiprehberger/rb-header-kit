# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    # Parses and builds Cache-Control header values.
    #
    # Supports common directives: max-age, s-maxage, no-cache, no-store,
    # public, private, must-revalidate, proxy-revalidate, no-transform, immutable.
    module CacheControl
      VALUE_DIRECTIVES = %w[max-age s-maxage max-stale min-fresh stale-while-revalidate stale-if-error].freeze

      # Parse a Cache-Control header string into a directive hash.
      #
      # Boolean directives become `true`. Value directives are converted to integers.
      # Keys are symbolized with hyphens replaced by underscores.
      #
      # @param header [String] the Cache-Control header value
      # @return [Hash{Symbol => true, Integer, String}] parsed directives
      def self.parse(header)
        return {} if header.nil? || header.strip.empty?

        directives = {}

        header.split(',').each do |part|
          part = part.strip
          next if part.empty?

          key, value = part.split('=', 2)
          key = key.strip.downcase
          sym = key.tr('-', '_').to_sym

          if value
            value = value.strip.delete('"')
            directives[sym] = VALUE_DIRECTIVES.include?(key) ? value.to_i : value
          else
            directives[sym] = true
          end
        end

        directives
      end

      # Build a Cache-Control header string from a directive hash.
      #
      # @param directives [Hash{Symbol => true, Integer, String}] directive hash
      # @return [String] formatted Cache-Control header value
      def self.build(directives)
        return '' if directives.nil? || directives.empty?

        parts = directives.map do |key, value|
          directive = key.to_s.tr('_', '-')
          value == true ? directive : "#{directive}=#{value}"
        end

        parts.join(', ')
      end
    end
  end
end
