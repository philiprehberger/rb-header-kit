# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::HeaderKit::Etag do
  describe '.match?' do
    it 'returns false for a nil header' do
      expect(described_class.match?(nil, 'abc')).to be false
    end

    it 'returns false for an empty header' do
      expect(described_class.match?('', 'abc')).to be false
    end

    it 'returns false for a whitespace-only header' do
      expect(described_class.match?('   ', 'abc')).to be false
    end

    it 'returns true for an exact strong match' do
      expect(described_class.match?('"abc"', 'abc')).to be true
    end

    it 'returns false when a strong ETag does not match' do
      expect(described_class.match?('"abc"', 'xyz')).to be false
    end

    it 'returns true when a list contains a matching entry' do
      expect(described_class.match?('"abc", "xyz"', 'xyz')).to be true
    end

    it 'returns false when a list has no matching entry' do
      expect(described_class.match?('"abc", "xyz"', 'nope')).to be false
    end

    it 'treats a weak-prefixed value as a match' do
      expect(described_class.match?('W/"abc"', 'abc')).to be true
    end

    it 'matches a weak entry inside a list' do
      expect(described_class.match?('W/"abc", W/"xyz"', 'xyz')).to be true
    end

    it 'matches the wildcard against any non-nil resource' do
      expect(described_class.match?('*', 'anything')).to be true
    end

    it 'returns false for a wildcard when the resource is nil' do
      expect(described_class.match?('*', nil)).to be false
    end

    it 'matches the wildcard when it appears inside a list' do
      expect(described_class.match?('"abc", *', 'whatever')).to be true
    end

    it 'unescapes backslash-escaped characters in quoted values' do
      expect(described_class.match?('"ab\\"c"', 'ab"c')).to be true
    end

    it 'does not split on commas inside quoted values' do
      expect(described_class.match?('"abc,def"', 'abc,def')).to be true
    end

    it 'handles extra whitespace between list entries' do
      expect(described_class.match?('  "abc"  ,   W/"xyz"  ', 'xyz')).to be true
    end

    it 'returns false when the resource is nil and no wildcard is present' do
      expect(described_class.match?('"abc"', nil)).to be false
    end
  end
end

RSpec.describe Philiprehberger::HeaderKit do
  describe '.etag_match?' do
    it 'delegates to Etag.match?' do
      expect(described_class.etag_match?('"abc"', 'abc')).to be true
      expect(described_class.etag_match?('"abc"', 'xyz')).to be false
    end
  end
end
