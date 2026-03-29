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

  describe '.build_accept' do
    it 'builds a simple Accept header' do
      result = described_class.build_accept([{ type: 'application/json' }])
      expect(result).to eq('application/json')
    end

    it 'builds multiple types' do
      types = [
        { type: 'text/html', quality: 1.0 },
        { type: 'application/json', quality: 0.9 }
      ]
      result = described_class.build_accept(types)
      expect(result).to eq('text/html, application/json;q=0.9')
    end

    it 'omits quality when 1.0' do
      result = described_class.build_accept([{ type: 'text/html', quality: 1.0 }])
      expect(result).to eq('text/html')
    end

    it 'includes quality when less than 1.0' do
      result = described_class.build_accept([{ type: 'text/html', quality: 0.5 }])
      expect(result).to eq('text/html;q=0.5')
    end

    it 'formats quality with minimal decimal places' do
      result = described_class.build_accept([{ type: 'text/html', quality: 0.8 }])
      expect(result).to eq('text/html;q=0.8')
    end

    it 'returns empty string for nil input' do
      expect(described_class.build_accept(nil)).to eq('')
    end

    it 'returns empty string for empty array' do
      expect(described_class.build_accept([])).to eq('')
    end

    it 'handles types without quality key' do
      result = described_class.build_accept([{ type: 'text/html' }, { type: 'text/plain' }])
      expect(result).to eq('text/html, text/plain')
    end

    it 'handles zero quality' do
      result = described_class.build_accept([{ type: 'text/html', quality: 0.0 }])
      expect(result).to include('q=0.0')
    end
  end

  describe '.parse_accept_language' do
    it 'parses a simple language tag' do
      result = described_class.parse_accept_language('en')
      expect(result).to eq([{ language: 'en', quality: 1.0 }])
    end

    it 'parses multiple languages with quality' do
      result = described_class.parse_accept_language('en;q=0.9, fr;q=1.0, de;q=0.5')
      expect(result.map { |e| e[:language] }).to eq(%w[fr en de])
      expect(result.map { |e| e[:quality] }).to eq([1.0, 0.9, 0.5])
    end

    it 'parses language with region subtag' do
      result = described_class.parse_accept_language('en-US, en-GB;q=0.8')
      expect(result.first[:language]).to eq('en-US')
      expect(result.last[:language]).to eq('en-GB')
    end

    it 'defaults quality to 1.0' do
      result = described_class.parse_accept_language('en-US')
      expect(result.first[:quality]).to eq(1.0)
    end

    it 'handles wildcard' do
      result = described_class.parse_accept_language('*')
      expect(result.first[:language]).to eq('*')
    end

    it 'returns empty array for nil input' do
      expect(described_class.parse_accept_language(nil)).to eq([])
    end

    it 'returns empty array for empty string' do
      expect(described_class.parse_accept_language('')).to eq([])
    end

    it 'sorts by quality descending' do
      result = described_class.parse_accept_language('de;q=0.1, en;q=0.9, fr;q=0.5')
      expect(result.first[:language]).to eq('en')
      expect(result.last[:language]).to eq('de')
    end

    it 'preserves order for equal quality values' do
      result = described_class.parse_accept_language('en, fr')
      languages = result.map { |e| e[:language] }
      expect(languages).to eq(%w[en fr])
    end

    it 'handles complex real-world header' do
      result = described_class.parse_accept_language('en-US,en;q=0.9,fr;q=0.8,de;q=0.7')
      expect(result.map { |e| e[:language] }).to eq(%w[en-US en fr de])
    end
  end

  describe '.negotiate_language' do
    it 'returns exact match' do
      result = described_class.negotiate_language('en, fr', %w[fr de])
      expect(result).to eq('fr')
    end

    it 'respects quality values' do
      result = described_class.negotiate_language('en;q=0.5, fr;q=0.9', %w[en fr])
      expect(result).to eq('fr')
    end

    it 'matches by prefix' do
      result = described_class.negotiate_language('en', %w[en-US en-GB])
      expect(result).to eq('en-US')
    end

    it 'matches base language from regional variant' do
      result = described_class.negotiate_language('en-US', %w[en de])
      expect(result).to eq('en')
    end

    it 'matches wildcard to first available' do
      result = described_class.negotiate_language('*', %w[de fr])
      expect(result).to eq('de')
    end

    it 'returns nil when no match' do
      result = described_class.negotiate_language('ja', %w[en fr])
      expect(result).to be_nil
    end

    it 'returns nil for empty available list' do
      expect(described_class.negotiate_language('en', [])).to be_nil
    end

    it 'returns first available when header is nil' do
      expect(described_class.negotiate_language(nil, %w[en fr])).to eq('en')
    end

    it 'returns nil when quality is zero' do
      result = described_class.negotiate_language('en;q=0', %w[en])
      expect(result).to be_nil
    end

    it 'handles case-insensitive matching' do
      result = described_class.negotiate_language('EN-US', %w[en-us])
      expect(result).to eq('en-us')
    end
  end

  describe '.parse_accept_encoding' do
    it 'parses a simple encoding' do
      result = described_class.parse_accept_encoding('gzip')
      expect(result).to eq([{ encoding: 'gzip', quality: 1.0 }])
    end

    it 'parses multiple encodings with quality' do
      result = described_class.parse_accept_encoding('gzip;q=1.0, deflate;q=0.5, br;q=0.8')
      expect(result.map { |e| e[:encoding] }).to eq(%w[gzip br deflate])
      expect(result.map { |e| e[:quality] }).to eq([1.0, 0.8, 0.5])
    end

    it 'defaults quality to 1.0' do
      result = described_class.parse_accept_encoding('br')
      expect(result.first[:quality]).to eq(1.0)
    end

    it 'handles identity encoding' do
      result = described_class.parse_accept_encoding('identity')
      expect(result.first[:encoding]).to eq('identity')
    end

    it 'handles wildcard' do
      result = described_class.parse_accept_encoding('*')
      expect(result.first[:encoding]).to eq('*')
    end

    it 'returns empty array for nil input' do
      expect(described_class.parse_accept_encoding(nil)).to eq([])
    end

    it 'returns empty array for empty string' do
      expect(described_class.parse_accept_encoding('')).to eq([])
    end

    it 'sorts by quality descending' do
      result = described_class.parse_accept_encoding('deflate;q=0.1, gzip;q=0.9, br;q=0.5')
      expect(result.first[:encoding]).to eq('gzip')
      expect(result.last[:encoding]).to eq('deflate')
    end

    it 'preserves order for equal quality values' do
      result = described_class.parse_accept_encoding('gzip, br')
      encodings = result.map { |e| e[:encoding] }
      expect(encodings).to eq(%w[gzip br])
    end

    it 'downcases encoding names' do
      result = described_class.parse_accept_encoding('GZIP, Deflate')
      expect(result.map { |e| e[:encoding] }).to eq(%w[gzip deflate])
    end
  end

  describe '.parse_authorization' do
    context 'with Bearer token' do
      it 'parses Bearer authorization' do
        result = described_class.parse_authorization('Bearer eyJhbGciOiJIUzI1NiJ9')
        expect(result[:scheme]).to eq('Bearer')
        expect(result[:credentials]).to eq('eyJhbGciOiJIUzI1NiJ9')
      end
    end

    context 'with Basic credentials' do
      it 'parses Basic authorization' do
        result = described_class.parse_authorization('Basic dXNlcjpwYXNz')
        expect(result[:scheme]).to eq('Basic')
        expect(result[:credentials]).to eq('dXNlcjpwYXNz')
      end
    end

    context 'with Digest parameters' do
      it 'parses Digest authorization' do
        header = 'Digest username="admin", realm="example", nonce="abc123", uri="/resource", response="def456"'
        result = described_class.parse_authorization(header)
        expect(result[:scheme]).to eq('Digest')
        expect(result[:params]).to be_a(Hash)
        expect(result[:params]['username']).to eq('admin')
        expect(result[:params]['realm']).to eq('example')
        expect(result[:params]['nonce']).to eq('abc123')
        expect(result[:params]['uri']).to eq('/resource')
        expect(result[:params]['response']).to eq('def456')
      end

      it 'handles unquoted Digest values' do
        header = 'Digest qop=auth, nc=00000001'
        result = described_class.parse_authorization(header)
        expect(result[:params]['qop']).to eq('auth')
        expect(result[:params]['nc']).to eq('00000001')
      end
    end

    it 'returns nil fields for nil input' do
      result = described_class.parse_authorization(nil)
      expect(result).to eq({ scheme: nil, credentials: nil })
    end

    it 'returns nil fields for empty string' do
      result = described_class.parse_authorization('')
      expect(result).to eq({ scheme: nil, credentials: nil })
    end

    it 'handles scheme-only without credentials' do
      result = described_class.parse_authorization('Bearer')
      expect(result[:scheme]).to eq('Bearer')
      expect(result[:credentials]).to be_nil
    end

    it 'handles unknown scheme' do
      result = described_class.parse_authorization('Custom token123')
      expect(result[:scheme]).to eq('Custom')
      expect(result[:credentials]).to eq('token123')
    end
  end

  describe '.parse_cookie' do
    it 'parses a single cookie' do
      result = described_class.parse_cookie('session=abc123')
      expect(result).to eq({ 'session' => 'abc123' })
    end

    it 'parses multiple cookies' do
      result = described_class.parse_cookie('session=abc123; user=john; theme=dark')
      expect(result).to eq({ 'session' => 'abc123', 'user' => 'john', 'theme' => 'dark' })
    end

    it 'handles cookies with equals in value' do
      result = described_class.parse_cookie('token=abc=123=xyz')
      expect(result).to eq({ 'token' => 'abc=123=xyz' })
    end

    it 'handles cookies without value' do
      result = described_class.parse_cookie('flag')
      expect(result).to eq({ 'flag' => '' })
    end

    it 'trims whitespace from names and values' do
      result = described_class.parse_cookie('  name  =  value  ')
      expect(result).to eq({ 'name' => 'value' })
    end

    it 'returns empty hash for nil input' do
      expect(described_class.parse_cookie(nil)).to eq({})
    end

    it 'returns empty hash for empty string' do
      expect(described_class.parse_cookie('')).to eq({})
    end

    it 'handles empty cookie value' do
      result = described_class.parse_cookie('name=')
      expect(result).to eq({ 'name' => '' })
    end
  end

  describe '.build_set_cookie' do
    it 'builds a simple Set-Cookie header' do
      result = described_class.build_set_cookie('session', 'abc123')
      expect(result).to eq('session=abc123')
    end

    it 'includes Expires attribute' do
      result = described_class.build_set_cookie('session', 'abc', expires: 'Thu, 01 Jan 2027 00:00:00 GMT')
      expect(result).to include('Expires=Thu, 01 Jan 2027 00:00:00 GMT')
    end

    it 'includes Max-Age attribute' do
      result = described_class.build_set_cookie('session', 'abc', max_age: 3600)
      expect(result).to include('Max-Age=3600')
    end

    it 'includes Secure flag' do
      result = described_class.build_set_cookie('session', 'abc', secure: true)
      expect(result).to include('Secure')
    end

    it 'includes HttpOnly flag' do
      result = described_class.build_set_cookie('session', 'abc', httponly: true)
      expect(result).to include('HttpOnly')
    end

    it 'includes SameSite attribute' do
      result = described_class.build_set_cookie('session', 'abc', samesite: 'Strict')
      expect(result).to include('SameSite=Strict')
    end

    it 'includes Path attribute' do
      result = described_class.build_set_cookie('session', 'abc', path: '/')
      expect(result).to include('Path=/')
    end

    it 'includes Domain attribute' do
      result = described_class.build_set_cookie('session', 'abc', domain: 'example.com')
      expect(result).to include('Domain=example.com')
    end

    it 'builds with all attributes' do
      result = described_class.build_set_cookie(
        'session', 'abc123',
        expires: 'Thu, 01 Jan 2027 00:00:00 GMT',
        max_age: 3600,
        secure: true,
        httponly: true,
        samesite: 'Lax',
        path: '/',
        domain: 'example.com'
      )
      expect(result).to eq(
        'session=abc123; Expires=Thu, 01 Jan 2027 00:00:00 GMT; Max-Age=3600; ' \
        'Domain=example.com; Path=/; Secure; HttpOnly; SameSite=Lax'
      )
    end

    it 'omits false boolean flags' do
      result = described_class.build_set_cookie('session', 'abc', secure: false, httponly: false)
      expect(result).to eq('session=abc')
    end

    it 'omits nil attributes' do
      result = described_class.build_set_cookie('session', 'abc', expires: nil, path: nil)
      expect(result).to eq('session=abc')
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
