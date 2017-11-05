# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    # Parses Accept-Encoding headers into structured encoding entries with quality values.
    module AcceptEncoding
      QUALITY_PATTERN = /\Aq\z/i

      # Parse an Accept-Encoding header string.
      #
      # @param header [String] the Accept-Encoding header value
      # @return [Array<Hash>] sorted by quality descending, each with :encoding, :quality
      def self.parse(header)
        return [] if header.nil? || header.strip.empty?

        entries = header.split(',').map { |entry| parse_entry(entry.strip) }
        entries.compact.sort_by { |e| [-e[:quality], entries.index(e)] }
      end

      # Parse a single encoding entry.
      #
      # @param entry [String] a single encoding with optional quality
      # @return [Hash, nil] parsed entry or nil if invalid
      def self.parse_entry(entry)
        return nil if entry.empty?

        parts = entry.split(';').map(&:strip)
        encoding = parts.shift
        return nil if encoding.nil? || encoding.empty?

        quality = 1.0

        parts.each do |param|
          key, value = param.split('=', 2).map(&:strip)
          next if key.nil? || key.empty?

          quality = parse_quality(value) if QUALITY_PATTERN.match?(key)
        end

        { encoding: encoding.downcase, quality: quality }
      end

      # Parse a quality value, clamping to [0.0, 1.0].
      #
      # @param value [String, nil] the quality string
      # @return [Float] parsed quality value
      def self.parse_quality(value)
        return 1.0 if value.nil? || value.empty?

        value.to_f.clamp(0.0, 1.0)
      end

      private_class_method :parse_entry, :parse_quality
    end
  end
end
