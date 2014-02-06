# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    # Content negotiation logic for matching Accept headers against available media types.
    module Negotiation
      # Find the best matching media type from available types based on an Accept header.
      #
      # Matching rules (RFC 7231):
      # 1. Exact type match
      # 2. Subtype wildcard (e.g., text/* matches text/html)
      # 3. Full wildcard (*/*) matches anything
      #
      # @param accept_header [String] the Accept header value
      # @param available [Array<String>] list of available media types
      # @return [String, nil] the best matching type, or nil if no match
      def self.negotiate(accept_header, available)
        return nil if available.nil? || available.empty?
        return available.first if accept_header.nil? || accept_header.strip.empty?

        accepted = Accept.parse(accept_header)
        return nil if accepted.empty?

        best_match = nil
        best_quality = -1.0
        best_specificity = -1

        accepted.each do |entry|
          available.each do |candidate|
            specificity = match_specificity(entry[:type], candidate)
            next unless specificity >= 0
            next unless entry[:quality] > best_quality ||
                        (entry[:quality] == best_quality && specificity > best_specificity)

            best_match = candidate
            best_quality = entry[:quality]
            best_specificity = specificity
          end
        end

        best_quality > 0.0 ? best_match : nil
      end

      # Calculate match specificity between an accept type pattern and a candidate.
      #
      # @param pattern [String] the accept type (may include wildcards)
      # @param candidate [String] the available media type
      # @return [Integer] specificity score (-1 = no match, 0 = */*, 1 = type/*, 2 = exact)
      def self.match_specificity(pattern, candidate)
        return 0 if pattern == '*/*'

        pattern_type, pattern_sub = pattern.downcase.split('/', 2)
        candidate_type, candidate_sub = candidate.downcase.split('/', 2)

        return -1 unless pattern_type == candidate_type || pattern_type == '*'

        if pattern_sub == '*'
          1
        elsif pattern_sub == candidate_sub
          2
        else
          -1
        end
      end

      private_class_method :match_specificity
    end
  end
end
