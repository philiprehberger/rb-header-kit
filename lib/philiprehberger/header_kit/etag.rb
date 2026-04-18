# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    # Evaluates If-None-Match / If-Match style header values against a
    # resource ETag.
    #
    # Accepts single ETags, comma-separated lists, weak-prefixed values
    # (e.g. `W/"abc"`), and the `*` wildcard. Strong and weak semantics
    # collapse to equality on the inner token — callers that need strict
    # strong/weak differentiation should implement that separately.
    module Etag
      module_function

      # Check whether a header value matches a resource ETag.
      #
      # @param header_value [String, nil] the raw If-None-Match / If-Match header
      # @param resource_etag [String, nil] the resource ETag (unquoted, no `W/` prefix)
      # @return [Boolean] true if any value in the header matches the resource
      def match?(header_value, resource_etag)
        return false if header_value.nil?

        stripped = header_value.strip
        return false if stripped.empty?

        tokens = split_values(stripped)
        return false if tokens.empty?

        tokens.any? { |token| token_matches?(token, resource_etag) }
      end

      # Split a header value into individual ETag tokens.
      #
      # Quoted sections (including escaped characters) are preserved so commas
      # inside a quoted ETag do not split the value.
      #
      # @param value [String] the header value to split
      # @return [Array<String>] trimmed, non-empty tokens
      def split_values(value)
        tokens = []
        buffer = +''
        in_quotes = false
        escaped = false

        value.each_char do |char|
          if escaped
            buffer << char
            escaped = false
          elsif in_quotes && char == '\\'
            buffer << char
            escaped = true
          elsif char == '"'
            buffer << char
            in_quotes = !in_quotes
          elsif char == ',' && !in_quotes
            tokens << buffer.strip unless buffer.strip.empty?
            buffer = +''
          else
            buffer << char
          end
        end

        tokens << buffer.strip unless buffer.strip.empty?
        tokens
      end

      # Determine whether a single token matches the resource ETag.
      #
      # @param token [String] a single header token
      # @param resource_etag [String, nil] the resource ETag
      # @return [Boolean] true if the token matches
      def token_matches?(token, resource_etag)
        return !resource_etag.nil? if token == '*'
        return false if resource_etag.nil?

        unwrap(token) == resource_etag
      end

      # Strip weak prefix and surrounding quotes from an ETag token.
      #
      # Backslash-escaped characters inside the quoted value are unescaped.
      #
      # @param token [String] a single ETag token
      # @return [String] the inner ETag value
      def unwrap(token)
        value = token.sub(%r{\AW/}i, '')

        return value unless value.start_with?('"') && value.end_with?('"') && value.length >= 2

        inner = value[1..-2]
        inner.gsub(/\\(.)/, '\1')
      end
    end
  end
end
