# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::HeaderKit do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.parse_accept' do
    it 'parses a simple Accept header' do
      result = described_class.parse_accept('text/html')
      expect(result).to eq([{ type: 'text/html', quality: 1.0, params: {} }])
    end

    it 'parses multiple types with quality values' do
      result = described_class.parse_accept('text/html;q=0.9, application/json;q=1.0, text/plain;q=0.5')
      expect(result.map { |e| e[:type] }).to eq(%w[application/json text/html text/plain])
      expect(result.map { |e| e[:quality] }).to eq([1.0, 0.9, 0.5])
    end

    it 'defaults quality to 1.0 when not specified' do
      result = described_class.parse_accept('application/json')
      expect(result.first[:quality]).to eq(1.0)
    end

    it 'preserves additional parameters' do
      result = described_class.parse_accept('text/html;level=1;q=0.7')
      expect(result.first[:params]).to eq({ 'level' => '1' })
    end

    it 'handles wildcards' do
      result = described_class.parse_accept('*/*')
      expect(result.first[:type]).to eq('*/*')
    end

    it 'returns empty array for nil input' do
      expect(described_class.parse_accept(nil)).to eq([])
    end

    it 'returns empty array for empty string' do
      expect(described_class.parse_accept('')).to eq([])
    end

    it 'sorts by quality descending' do
      result = described_class.parse_accept('text/plain;q=0.1, text/html;q=0.9, application/json;q=0.5')
      expect(result.first[:type]).to eq('text/html')
      expect(result.last[:type]).to eq('text/plain')
    end

    it 'preserves order for equal quality values' do
      result = described_class.parse_accept('text/html, application/json')
      types = result.map { |e| e[:type] }
      expect(types).to eq(%w[text/html application/json])
    end
  end

  describe '.parse_cache_control' do
    it 'parses max-age directive' do
      result = described_class.parse_cache_control('max-age=3600')
      expect(result[:max_age]).to eq(3600)
    end

    it 'parses boolean directives' do
      result = described_class.parse_cache_control('no-cache, no-store')
      expect(result[:no_cache]).to be true
      expect(result[:no_store]).to be true
    end

    it 'parses mixed directives' do
      result = described_class.parse_cache_control('public, max-age=86400, must-revalidate')
      expect(result).to eq({ public: true, max_age: 86_400, must_revalidate: true })
    end

    it 'parses private directive' do
      result = described_class.parse_cache_control('private, no-cache')
      expect(result[:private]).to be true
      expect(result[:no_cache]).to be true
    end

    it 'parses s-maxage directive' do
      result = described_class.parse_cache_control('s-maxage=600')
      expect(result[:s_maxage]).to eq(600)
    end

    it 'returns empty hash for nil input' do
      expect(described_class.parse_cache_control(nil)).to eq({})
    end

    it 'returns empty hash for empty string' do
      expect(described_class.parse_cache_control('')).to eq({})
    end

    it 'parses immutable directive' do
      result = described_class.parse_cache_control('max-age=31536000, immutable')
      expect(result[:immutable]).to be true
      expect(result[:max_age]).to eq(31_536_000)
    end
  end

  describe '.build_cache_control' do
    it 'builds a simple max-age directive' do
      expect(described_class.build_cache_control({ max_age: 3600 })).to eq('max-age=3600')
    end

    it 'builds boolean directives' do
      result = described_class.build_cache_control({ no_cache: true, no_store: true })
      expect(result).to eq('no-cache, no-store')
    end

    it 'builds mixed directives' do
      result = described_class.build_cache_control({ public: true, max_age: 86_400, must_revalidate: true })
      expect(result).to eq('public, max-age=86400, must-revalidate')
    end

    it 'returns empty string for nil input' do
      expect(described_class.build_cache_control(nil)).to eq('')
    end

    it 'returns empty string for empty hash' do
      expect(described_class.build_cache_control({})).to eq('')
    end

    it 'round-trips through parse and build' do
      original = 'public, max-age=3600, must-revalidate'
      parsed = described_class.parse_cache_control(original)
      rebuilt = described_class.build_cache_control(parsed)
      expect(rebuilt).to eq(original)
    end
  end

  describe '.parse_content_type' do
    it 'parses a simple media type' do
      result = described_class.parse_content_type('application/json')
      expect(result[:media_type]).to eq('application/json')
      expect(result[:charset]).to be_nil
      expect(result[:boundary]).to be_nil
    end

    it 'parses media type with charset' do
      result = described_class.parse_content_type('text/html; charset=utf-8')
      expect(result[:media_type]).to eq('text/html')
      expect(result[:charset]).to eq('utf-8')
    end

    it 'parses media type with boundary' do
      result = described_class.parse_content_type('multipart/form-data; boundary=----WebKitFormBoundary')
      expect(result[:media_type]).to eq('multipart/form-data')
      expect(result[:boundary]).to eq('----WebKitFormBoundary')
    end

    it 'parses media type with charset and boundary' do
      result = described_class.parse_content_type('multipart/form-data; charset=utf-8; boundary=abc123')
      expect(result[:media_type]).to eq('multipart/form-data')
      expect(result[:charset]).to eq('utf-8')
      expect(result[:boundary]).to eq('abc123')
    end

    it 'handles quoted values' do
      result = described_class.parse_content_type('text/html; charset="utf-8"')
      expect(result[:charset]).to eq('utf-8')
    end

    it 'returns nil fields for nil input' do
      result = described_class.parse_content_type(nil)
      expect(result).to eq({ media_type: nil, charset: nil, boundary: nil })
    end

    it 'returns nil fields for empty string' do
      result = described_class.parse_content_type('')
      expect(result).to eq({ media_type: nil, charset: nil, boundary: nil })
    end

    it 'downcases the media type' do
      result = described_class.parse_content_type('Application/JSON')
      expect(result[:media_type]).to eq('application/json')
    end
  end

  describe '.parse_link' do
    it 'parses a single link with rel' do
      result = described_class.parse_link('<https://example.com/next>; rel="next"')
      expect(result.length).to eq(1)
      expect(result.first[:uri]).to eq('https://example.com/next')
      expect(result.first[:rel]).to eq('next')
    end

    it 'parses multiple links' do
      header = '<https://example.com/1>; rel="prev", <https://example.com/3>; rel="next"'
      result = described_class.parse_link(header)
      expect(result.length).to eq(2)
      expect(result[0][:rel]).to eq('prev')
      expect(result[1][:rel]).to eq('next')
    end

    it 'parses link with type and title' do
      header = '<https://example.com>; rel="alternate"; type="text/html"; title="Example"'
      result = described_class.parse_link(header)
      expect(result.first[:type]).to eq('text/html')
      expect(result.first[:title]).to eq('Example')
    end

    it 'returns nil for missing parameters' do
      result = described_class.parse_link('<https://example.com>')
      expect(result.first[:rel]).to be_nil
      expect(result.first[:type]).to be_nil
      expect(result.first[:title]).to be_nil
    end

    it 'returns empty array for nil input' do
      expect(described_class.parse_link(nil)).to eq([])
    end

    it 'returns empty array for empty string' do
      expect(described_class.parse_link('')).to eq([])
    end
  end

  describe '.build_link' do
    it 'builds a single link' do
      result = described_class.build_link([{ uri: 'https://example.com', rel: 'next' }])
      expect(result).to eq('<https://example.com>; rel="next"')
    end

    it 'builds multiple links' do
      links = [
        { uri: 'https://example.com/1', rel: 'prev' },
        { uri: 'https://example.com/3', rel: 'next' }
      ]
      result = described_class.build_link(links)
      expect(result).to eq('<https://example.com/1>; rel="prev", <https://example.com/3>; rel="next"')
    end

    it 'builds link with all parameters' do
      links = [{ uri: 'https://example.com', rel: 'alternate', type: 'text/html', title: 'Example' }]
      result = described_class.build_link(links)
      expect(result).to eq('<https://example.com>; rel="alternate"; type="text/html"; title="Example"')
    end

    it 'omits nil parameters' do
      result = described_class.build_link([{ uri: 'https://example.com', rel: nil, type: nil, title: nil }])
      expect(result).to eq('<https://example.com>')
    end

    it 'returns empty string for nil input' do
      expect(described_class.build_link(nil)).to eq('')
    end

    it 'returns empty string for empty array' do
      expect(described_class.build_link([])).to eq('')
    end

    it 'round-trips through parse and build' do
      original = '<https://example.com/next>; rel="next"'
      parsed = described_class.parse_link(original)
      rebuilt = described_class.build_link(parsed)
      expect(rebuilt).to eq(original)
    end
  end

  describe '.negotiate' do
    it 'returns exact match' do
      result = described_class.negotiate('application/json', %w[text/html application/json])
      expect(result).to eq('application/json')
    end

    it 'respects quality values' do
      result = described_class.negotiate(
        'text/html;q=0.5, application/json;q=0.9',
        %w[text/html application/json]
      )
      expect(result).to eq('application/json')
    end

    it 'matches subtype wildcard' do
      result = described_class.negotiate('text/*', %w[application/json text/plain])
      expect(result).to eq('text/plain')
    end

    it 'matches full wildcard' do
      result = described_class.negotiate('*/*', %w[application/json])
      expect(result).to eq('application/json')
    end

    it 'returns nil when no match' do
      result = described_class.negotiate('image/png', %w[text/html application/json])
      expect(result).to be_nil
    end

    it 'returns nil for empty available list' do
      expect(described_class.negotiate('text/html', [])).to be_nil
    end

    it 'returns first available when accept is nil' do
      expect(described_class.negotiate(nil, %w[text/html])).to eq('text/html')
    end

    it 'prefers more specific match' do
      result = described_class.negotiate(
        'text/html, text/*;q=0.9',
        %w[text/html text/plain]
      )
      expect(result).to eq('text/html')
    end

    it 'returns nil when quality is zero' do
      result = described_class.negotiate('text/html;q=0', %w[text/html])
      expect(result).to be_nil
    end

    it 'handles complex real-world Accept header' do
      accept = 'text/html, application/xhtml+xml, application/xml;q=0.9, */*;q=0.8'
      result = described_class.negotiate(accept, %w[application/json text/html])
      expect(result).to eq('text/html')
    end
  end
end
