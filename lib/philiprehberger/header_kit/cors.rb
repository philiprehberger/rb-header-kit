# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    module Cors
      module_function

      def parse(headers)
        result = {}
        result[:origin] = headers['Origin'] || headers['origin']
        result[:method] = headers['Access-Control-Request-Method'] || headers['access-control-request-method']
        request_headers = headers['Access-Control-Request-Headers'] || headers['access-control-request-headers']
        result[:headers] = request_headers&.split(',')&.map(&:strip) || []
        result
      end

      def build(origin:, methods: ['GET'], headers: [], max_age: nil, credentials: false, expose: [])
        result = {}
        result['Access-Control-Allow-Origin'] = origin
        result['Access-Control-Allow-Methods'] = Array(methods).join(', ')
        result['Access-Control-Allow-Headers'] = Array(headers).join(', ') unless headers.empty?
        result['Access-Control-Max-Age'] = max_age.to_s if max_age
        result['Access-Control-Allow-Credentials'] = 'true' if credentials
        result['Access-Control-Expose-Headers'] = Array(expose).join(', ') unless expose.empty?
        result
      end
    end
  end
end
