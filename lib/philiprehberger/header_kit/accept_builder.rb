# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    # Builds Accept header strings from structured type entries.
    module AcceptBuilder
      # Build an Accept header string from an array of type hashes.
      #
      # @param types [Array<Hash>] each with :type and optional :quality
      # @return [String] formatted Accept header value
      def self.build(types)
        return '' if types.nil? || types.empty?

        parts = types.map do |entry|
          type = entry[:type]
          quality = entry[:quality]

          if quality && quality < 1.0
            "#{type};q=#{format_quality(quality)}"
          else
            type
          end
        end

        parts.join(', ')
      end

      # Format a quality value, removing trailing zeros.
      #
      # @param quality [Float] the quality value
      # @return [String] formatted quality string
      def self.format_quality(quality)
        formatted = format('%.3f', quality)
        formatted.sub(/0+\z/, '').sub(/\.\z/, '.0')
      end

      private_class_method :format_quality
    end
  end
end
