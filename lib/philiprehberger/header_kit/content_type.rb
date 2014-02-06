# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    # Parses Content-Type header values into media type, charset, and boundary components.
    module ContentType
      # Parse a Content-Type header string.
      #
      # @param header [String] the Content-Type header value
      # @return [Hash] with :media_type, :charset, :boundary keys
      def self.parse(header)
        result = { media_type: nil, charset: nil, boundary: nil }
        return result if header.nil? || header.strip.empty?

        parts = header.split(';').map(&:strip)
        result[:media_type] = parts.shift&.downcase

        parts.each do |param|
          key, value = param.split('=', 2).map(&:strip)
          next if key.nil? || key.empty?

          value = unquote(value) if value

          case key.downcase
          when 'charset'
            result[:charset] = value
          when 'boundary'
            result[:boundary] = value
          end
        end

        result
      end

      # Remove surrounding double quotes from a value.
      #
      # @param value [String, nil] the value to unquote
      # @return [String, nil] unquoted value
      def self.unquote(value)
        return value if value.nil?

        value = value.strip
        if value.start_with?('"') && value.end_with?('"')
          value[1..-2]
        else
          value
        end
      end

      private_class_method :unquote
    end
  end
end
