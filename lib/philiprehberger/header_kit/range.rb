# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    # Parses and builds the HTTP Range request header (RFC 7233 §3.1).
    #
    # Format: `<unit>=<start>-<end>[, <start>-<end>]*`
    # Supports byte ranges, suffix ranges (`-N`), and open-ended ranges (`N-`).
    module Range
      module_function

      # Parse a Range header value.
      #
      # @param header [String, nil] the raw header value
      # @return [Hash{Symbol => Object}, nil] hash with :unit (String) and :ranges
      #   (Array of Hash with :first/:last keys, where either may be nil for
      #   open-ended), or nil for nil/blank/invalid input
      # @example
      #   parse('bytes=0-499')        # => { unit: 'bytes', ranges: [{ first: 0, last: 499 }] }
      #   parse('bytes=500-')         # => { unit: 'bytes', ranges: [{ first: 500, last: nil }] }
      #   parse('bytes=-500')         # => { unit: 'bytes', ranges: [{ first: nil, last: 500 }] }
      #   parse('bytes=0-99, 200-')   # => { unit: 'bytes', ranges: [{ first: 0, last: 99 }, { first: 200, last: nil }] }
      def parse(header)
        return nil if header.nil?

        header = header.to_s.strip
        return nil if header.empty?

        unit, _, spec = header.partition('=')
        unit = unit.strip
        spec = spec.strip
        return nil if unit.empty? || spec.empty?

        ranges = spec.split(',').map { |part| parse_range(part.strip) }
        return nil if ranges.any?(&:nil?)

        { unit: unit, ranges: ranges }
      end

      # Build a Range header value.
      #
      # @param unit [String] the range unit (e.g. 'bytes')
      # @param ranges [Array<Hash, Array, Range>] each as `{ first:, last: }`,
      #   a `[first, last]` array, or a Ruby `Range` (inclusive)
      # @return [String] formatted Range header
      # @example
      #   build('bytes', [{ first: 0, last: 499 }])           # => "bytes=0-499"
      #   build('bytes', [[0, 499], [500, nil]])              # => "bytes=0-499, 500-"
      #   build('bytes', [(0..99), { first: nil, last: 50 }]) # => "bytes=0-99, -50"
      def build(unit, ranges)
        list = ranges.is_a?(Array) ? ranges : [ranges]
        formatted = list.map { |r| format_range(r) }
        "#{unit}=#{formatted.join(', ')}"
      end

      def parse_range(raw)
        return nil unless raw.match?(/\A-?\d*-\d*\z/)
        return nil if raw == '-'

        first_str, _, last_str = raw.partition('-')
        first = first_str.empty? ? nil : Integer(first_str, 10)
        last = last_str.empty? ? nil : Integer(last_str, 10)
        return nil if first.nil? && last.nil?
        return nil if first && last && first > last

        { first: first, last: last }
      rescue ArgumentError
        nil
      end
      private_class_method :parse_range

      def format_range(spec)
        first, last =
          case spec
          when ::Range then [spec.first, spec.exclude_end? ? spec.last - 1 : spec.last]
          when Array then [spec[0], spec[1]]
          when Hash then [spec[:first] || spec['first'], spec[:last] || spec['last']]
          else raise ArgumentError, "Unsupported range entry: #{spec.inspect}"
          end

        "#{first}-#{last}"
      end
      private_class_method :format_range
    end
  end
end
