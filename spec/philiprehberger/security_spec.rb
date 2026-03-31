# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::HeaderKit::Security do
  describe '.headers' do
    it 'returns default security headers' do
      result = described_class.headers

      expect(result['X-Content-Type-Options']).to eq('nosniff')
      expect(result['X-Frame-Options']).to eq('DENY')
      expect(result['X-XSS-Protection']).to eq('0')
      expect(result['Referrer-Policy']).to eq('strict-origin-when-cross-origin')
    end

    it 'does not include HSTS or CSP by default' do
      result = described_class.headers

      expect(result).not_to have_key('Strict-Transport-Security')
      expect(result).not_to have_key('Content-Security-Policy')
    end

    it 'overrides frame options with custom value' do
      result = described_class.headers(frame: 'SAMEORIGIN')

      expect(result['X-Frame-Options']).to eq('SAMEORIGIN')
    end

    it 'overrides content type options with custom value' do
      result = described_class.headers(content_type_options: 'custom')

      expect(result['X-Content-Type-Options']).to eq('custom')
    end

    it 'overrides referrer policy with custom value' do
      result = described_class.headers(referrer_policy: 'no-referrer')

      expect(result['Referrer-Policy']).to eq('no-referrer')
    end

    it 'adds HSTS when provided' do
      result = described_class.headers(hsts: 'max-age=31536000; includeSubDomains')

      expect(result['Strict-Transport-Security']).to eq('max-age=31536000; includeSubDomains')
    end

    it 'adds CSP when provided' do
      result = described_class.headers(csp: "default-src 'self'")

      expect(result['Content-Security-Policy']).to eq("default-src 'self'")
    end
  end
end
