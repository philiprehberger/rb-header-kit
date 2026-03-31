# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    module Forwarded
      module_function

      def parse(header)
        return [] if header.nil? || header.empty?

        header.split(',').map do |part|
          entry = {}
          part.strip.split(';').each do |pair|
            key, value = pair.strip.split('=', 2)
            next unless key && value

            entry[key.strip.downcase.to_sym] = unquote(value.strip)
          end
          entry
        end
      end

      def parse_via(header)
        return [] if header.nil? || header.empty?

        header.split(',').map do |entry|
          parts = entry.strip.split(/\s+/, 3)
          result = {}
          if parts.length >= 2
            result[:protocol] = parts[0]
            result[:host] = parts[1]
            result[:comment] = parts[2] if parts[2]
          else
            result[:host] = parts[0]
          end
          result
        end
      end

      def unquote(value)
        value.start_with?('"') && value.end_with?('"') ? value[1..-2] : value
      end

      private_class_method :unquote
    end
  end
end
