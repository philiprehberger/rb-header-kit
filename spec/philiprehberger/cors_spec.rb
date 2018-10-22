# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::HeaderKit::Cors do
  describe '.parse' do
    it 'extracts origin, method, and headers from request hash' do
      headers = {
        'Origin' => 'https://example.com',
        'Access-Control-Request-Method' => 'POST',
        'Access-Control-Request-Headers' => 'Content-Type, Authorization'
      }
      result = described_class.parse(headers)

      expect(result[:origin]).to eq('https://example.com')
      expect(result[:method]).to eq('POST')
      expect(result[:headers]).to eq(%w[Content-Type Authorization])
    end

    it 'handles lowercase header keys' do
      headers = {
        'origin' => 'https://example.com',
        'access-control-request-method' => 'PUT',
        'access-control-request-headers' => 'X-Custom'
      }
      result = described_class.parse(headers)

      expect(result[:origin]).to eq('https://example.com')
      expect(result[:method]).to eq('PUT')
      expect(result[:headers]).to eq(['X-Custom'])
    end

    it 'returns empty headers array when no request headers present' do
      result = described_class.parse({})

      expect(result[:origin]).to be_nil
      expect(result[:method]).to be_nil
      expect(result[:headers]).to eq([])
    end
  end

  describe '.build' do
    it 'generates basic CORS headers with origin and default method' do
      result = described_class.build(origin: '*')

      expect(result['Access-Control-Allow-Origin']).to eq('*')
      expect(result['Access-Control-Allow-Methods']).to eq('GET')
    end

    it 'generates headers with all options' do
      result = described_class.build(
        origin: 'https://example.com',
        methods: %w[GET POST PUT],
        headers: %w[Content-Type Authorization],
        max_age: 3600,
        credentials: true,
        expose: ['X-Request-Id']
      )

      expect(result['Access-Control-Allow-Origin']).to eq('https://example.com')
      expect(result['Access-Control-Allow-Methods']).to eq('GET, POST, PUT')
      expect(result['Access-Control-Allow-Headers']).to eq('Content-Type, Authorization')
      expect(result['Access-Control-Max-Age']).to eq('3600')
      expect(result['Access-Control-Allow-Credentials']).to eq('true')
      expect(result['Access-Control-Expose-Headers']).to eq('X-Request-Id')
    end

    it 'omits optional headers when not provided' do
      result = described_class.build(origin: '*')

      expect(result).not_to have_key('Access-Control-Allow-Headers')
      expect(result).not_to have_key('Access-Control-Max-Age')
      expect(result).not_to have_key('Access-Control-Allow-Credentials')
      expect(result).not_to have_key('Access-Control-Expose-Headers')
    end
  end
end
