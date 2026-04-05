# frozen_string_literal: true

require 'time'

module Philiprehberger
  module HeaderKit
    module RetryAfter
      module_function

      def parse(header)
        return nil if header.nil? || header.empty?

        if header.match?(/\A\d+\z/)
          { seconds: header.to_i }
        else
          { date: Time.httpdate(header) }
        end
      end
    end
  end
end
