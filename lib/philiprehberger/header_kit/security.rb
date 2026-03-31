# frozen_string_literal: true

module Philiprehberger
  module HeaderKit
    module Security
      DEFAULTS = {
        content_type_options: 'nosniff',
        frame_options: 'DENY',
        xss_protection: '0',
        referrer_policy: 'strict-origin-when-cross-origin'
      }.freeze

      module_function

      def headers(hsts: nil, csp: nil, frame: nil, content_type_options: nil, referrer_policy: nil)
        result = {}
        result['X-Content-Type-Options'] = content_type_options || DEFAULTS[:content_type_options]
        result['X-Frame-Options'] = frame || DEFAULTS[:frame_options]
        result['X-XSS-Protection'] = DEFAULTS[:xss_protection]
        result['Referrer-Policy'] = referrer_policy || DEFAULTS[:referrer_policy]
        result['Strict-Transport-Security'] = hsts if hsts
        result['Content-Security-Policy'] = csp if csp
        result
      end
    end
  end
end
