# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    # Parses and builds RFC 8288 Link header values.
    #
    # Each link entry contains a URI and optional parameters such as rel, type, and title.
    module Link
      URI_PATTERN = /<([^>]*)>/

      # Parse a Link header string into an array of link entries.
      #
      # @param header [String] the Link header value
      # @return [Array<Hash>] each with :uri, :rel, :type, :title keys
      def self.parse(header)
        return [] if header.nil? || header.strip.empty?

        header.split(/,(?=\s*<)/).map { |entry| parse_entry(entry.strip) }.compact
      end

      # Build a Link header string from an array of link hashes.
      #
      # @param links [Array<Hash>] each with :uri and optional :rel, :type, :title
      # @return [String] formatted Link header value
      def self.build(links)
        return '' if links.nil? || links.empty?

        parts = links.map do |link|
          entry = "<#{link[:uri]}>"
          entry += "; rel=\"#{link[:rel]}\"" if link[:rel]
          entry += "; type=\"#{link[:type]}\"" if link[:type]
          entry += "; title=\"#{link[:title]}\"" if link[:title]
          entry
        end

        parts.join(', ')
      end

      # Parse a single Link entry.
      #
      # @param entry [String] a single link entry
      # @return [Hash, nil] parsed link or nil if invalid
      def self.parse_entry(entry)
        match = URI_PATTERN.match(entry)
        return nil unless match

        uri = match[1]
        result = { uri: uri, rel: nil, type: nil, title: nil }

        params_str = entry[match.end(0)..]
        return result if params_str.nil? || params_str.strip.empty?

        params_str.split(';').each do |param|
          param = param.strip
          next if param.empty?

          key, value = param.split('=', 2).map(&:strip)
          next if key.nil? || key.empty? || value.nil?

          value = unquote(value)

          case key.downcase
          when 'rel'
            result[:rel] = value
          when 'type'
            result[:type] = value
          when 'title'
            result[:title] = value
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

      private_class_method :parse_entry, :unquote
    end
  end
end
