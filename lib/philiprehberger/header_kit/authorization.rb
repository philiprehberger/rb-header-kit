# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    # Parses Authorization headers for Bearer, Basic, and Digest schemes.
    module Authorization
      DIGEST_PARAM_PATTERN = %r{(\w+)=(?:"([^"]*)"|([\w+/=]+))}

      # Parse an Authorization header string.
      #
      # @param header [String] the Authorization header value
      # @return [Hash] with :scheme and :credentials (Bearer/Basic) or :params (Digest)
      def self.parse(header)
        return { scheme: nil, credentials: nil } if header.nil? || header.strip.empty?

        stripped = header.strip
        space_index = stripped.index(' ')

        unless space_index
          return { scheme: stripped, credentials: nil }
        end

        scheme = stripped[0...space_index]
        rest = stripped[(space_index + 1)..].strip

        case scheme.downcase
        when 'bearer', 'basic'
          { scheme: scheme, credentials: rest }
        when 'digest'
          { scheme: scheme, params: parse_digest_params(rest) }
        else
          { scheme: scheme, credentials: rest }
        end
      end

      # Parse Digest authorization parameters.
      #
      # @param params_str [String] the parameter string after "Digest "
      # @return [Hash{String => String}] parsed key-value parameters
      def self.parse_digest_params(params_str)
        params = {}

        params_str.scan(DIGEST_PARAM_PATTERN).each do |key, quoted_value, unquoted_value|
          params[key] = quoted_value || unquoted_value
        end

        params
      end

      private_class_method :parse_digest_params
    end
  end
end
