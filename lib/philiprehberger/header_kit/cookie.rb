# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    # Parses Cookie headers and builds Set-Cookie header strings.
    module Cookie
      # Parse a Cookie header string into a name-value hash.
      #
      # @param header [String] the Cookie header value
      # @return [Hash{String => String}] cookie name-value pairs
      def self.parse(header)
        return {} if header.nil? || header.strip.empty?

        cookies = {}

        header.split(';').each do |pair|
          pair = pair.strip
          next if pair.empty?

          name, value = pair.split('=', 2)
          next if name.nil? || name.strip.empty?

          cookies[name.strip] = (value || '').strip
        end

        cookies
      end

      # Build a Set-Cookie header string.
      #
      # @param name [String] cookie name
      # @param value [String] cookie value
      # @param expires [String, nil] Expires attribute value
      # @param max_age [Integer, nil] Max-Age attribute value
      # @param secure [Boolean] include Secure flag
      # @param httponly [Boolean] include HttpOnly flag
      # @param samesite [String, nil] SameSite attribute (Strict, Lax, None)
      # @param path [String, nil] Path attribute
      # @param domain [String, nil] Domain attribute
      # @return [String] formatted Set-Cookie header value
      def self.build_set_cookie(name, value, expires: nil, max_age: nil, secure: false, # rubocop:disable Metrics/ParameterLists
                                httponly: false, samesite: nil, path: nil, domain: nil)
        parts = ["#{name}=#{value}"]
        parts << "Expires=#{expires}" if expires
        parts << "Max-Age=#{max_age}" if max_age
        parts << "Domain=#{domain}" if domain
        parts << "Path=#{path}" if path
        parts << 'Secure' if secure
        parts << 'HttpOnly' if httponly
        parts << "SameSite=#{samesite}" if samesite

        parts.join('; ')
      end
    end
  end
end
