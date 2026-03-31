# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::HeaderKit::Forwarded do
  describe '.parse' do
    it 'parses a single forwarded entry' do
      result = described_class.parse('for=192.0.2.60;proto=http;by=203.0.113.43')

      expect(result.length).to eq(1)
      expect(result[0][:for]).to eq('192.0.2.60')
      expect(result[0][:proto]).to eq('http')
      expect(result[0][:by]).to eq('203.0.113.43')
    end

    it 'parses multiple forwarded entries' do
      result = described_class.parse('for=192.0.2.43, for=198.51.100.178')

      expect(result.length).to eq(2)
      expect(result[0][:for]).to eq('192.0.2.43')
      expect(result[1][:for]).to eq('198.51.100.178')
    end

    it 'handles quoted values' do
      result = described_class.parse('for="[2001:db8::1]";proto=https')

      expect(result[0][:for]).to eq('[2001:db8::1]')
      expect(result[0][:proto]).to eq('https')
    end

    it 'returns empty array for nil' do
      expect(described_class.parse(nil)).to eq([])
    end

    it 'returns empty array for empty string' do
      expect(described_class.parse('')).to eq([])
    end
  end

  describe '.parse_via' do
    it 'parses protocol and host' do
      result = described_class.parse_via('1.1 vegur')

      expect(result.length).to eq(1)
      expect(result[0][:protocol]).to eq('1.1')
      expect(result[0][:host]).to eq('vegur')
    end

    it 'parses multiple via entries' do
      result = described_class.parse_via('1.0 fred, 1.1 p.example.net')

      expect(result.length).to eq(2)
      expect(result[0][:protocol]).to eq('1.0')
      expect(result[0][:host]).to eq('fred')
      expect(result[1][:protocol]).to eq('1.1')
      expect(result[1][:host]).to eq('p.example.net')
    end

    it 'handles entries with comments' do
      result = described_class.parse_via('1.1 vegur (CloudFront)')

      expect(result[0][:protocol]).to eq('1.1')
      expect(result[0][:host]).to eq('vegur')
      expect(result[0][:comment]).to eq('(CloudFront)')
    end

    it 'handles single-part entries as host only' do
      result = described_class.parse_via('vegur')

      expect(result[0][:host]).to eq('vegur')
      expect(result[0]).not_to have_key(:protocol)
    end

    it 'returns empty array for nil' do
      expect(described_class.parse_via(nil)).to eq([])
    end

    it 'returns empty array for empty string' do
      expect(described_class.parse_via('')).to eq([])
    end
  end
end
