# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    # Parses Accept-Language headers into structured language entries with quality values.
    module AcceptLanguage
      QUALITY_PATTERN = /\Aq\z/i

      # Parse an Accept-Language header string.
      #
      # @param header [String] the Accept-Language header value
      # @return [Array<Hash>] sorted by quality descending, each with :language, :quality
      def self.parse(header)
        return [] if header.nil? || header.strip.empty?

        entries = header.split(',').map { |entry| parse_entry(entry.strip) }
        entries.compact.sort_by { |e| [-e[:quality], entries.index(e)] }
      end

      # Negotiate the best language match from available languages.
      #
      # @param header [String] the Accept-Language header value
      # @param available [Array<String>] list of available language tags
      # @return [String, nil] the best matching language, or nil if no match
      def self.negotiate(header, available)
        return nil if available.nil? || available.empty?
        return available.first if header.nil? || header.strip.empty?

        parsed = parse(header)
        return nil if parsed.empty?

        parsed.each do |entry|
          next if entry[:quality] <= 0.0

          match = find_match(entry[:language], available)
          return match if match
        end

        nil
      end

      # Parse a single language entry.
      #
      # @param entry [String] a single language tag with optional quality
      # @return [Hash, nil] parsed entry or nil if invalid
      def self.parse_entry(entry)
        return nil if entry.empty?

        parts = entry.split(';').map(&:strip)
        language = parts.shift
        return nil if language.nil? || language.empty?

        quality = 1.0

        parts.each do |param|
          key, value = param.split('=', 2).map(&:strip)
          next if key.nil? || key.empty?

          quality = parse_quality(value) if QUALITY_PATTERN.match?(key)
        end

        { language: language, quality: quality }
      end

      # Parse a quality value, clamping to [0.0, 1.0].
      #
      # @param value [String, nil] the quality string
      # @return [Float] parsed quality value
      def self.parse_quality(value)
        return 1.0 if value.nil? || value.empty?

        value.to_f.clamp(0.0, 1.0)
      end

      # Find the best match for a language tag among available languages.
      #
      # @param tag [String] the requested language tag
      # @param available [Array<String>] available language tags
      # @return [String, nil] matching language or nil
      def self.find_match(tag, available)
        return available.first if tag == '*'

        downcased = tag.downcase
        exact = available.find { |a| a.downcase == downcased }
        return exact if exact

        prefix = available.find { |a| a.downcase.start_with?("#{downcased}-") }
        return prefix if prefix

        base = downcased.split('-').first
        available.find { |a| a.downcase.split('-').first == base }
      end

      private_class_method :parse_entry, :parse_quality, :find_match
    end
  end
end
