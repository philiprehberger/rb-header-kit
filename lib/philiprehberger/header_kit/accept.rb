# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    # Parses Accept headers into structured media type entries with quality values.
    #
    # Each entry contains the media type, a quality factor (0.0-1.0), and any
    # additional parameters from the header.
    module Accept
      QUALITY_PATTERN = /\Aq\z/i

      # Parse an Accept header string.
      #
      # @param header [String] the Accept header value
      # @return [Array<Hash>] sorted by quality descending, each with :type, :quality, :params
      def self.parse(header)
        return [] if header.nil? || header.strip.empty?

        entries = header.split(',').map { |entry| parse_entry(entry.strip) }
        entries.compact.sort_by { |e| [-e[:quality], entries.index(e)] }
      end

      # Parse a single media type entry from an Accept header.
      #
      # @param entry [String] a single media type with optional parameters
      # @return [Hash, nil] parsed entry or nil if invalid
      def self.parse_entry(entry)
        return nil if entry.empty?

        parts = entry.split(';').map(&:strip)
        type = parts.shift
        return nil if type.nil? || type.empty?

        quality = 1.0
        params = {}

        parts.each do |param|
          key, value = param.split('=', 2).map(&:strip)
          next if key.nil? || key.empty?

          if QUALITY_PATTERN.match?(key)
            quality = parse_quality(value)
          else
            params[key] = value
          end
        end

        { type: type, quality: quality, params: params }
      end

      # Parse a quality value, clamping to [0.0, 1.0].
      #
      # @param value [String, nil] the quality string
      # @return [Float] parsed quality value
      def self.parse_quality(value)
        return 1.0 if value.nil? || value.empty?

        q = value.to_f
        q.clamp(0.0, 1.0)
      end

      private_class_method :parse_entry, :parse_quality
    end
  end
end
