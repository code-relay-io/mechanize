require 'mechanize/test_case'

class TestMechanizeParser < Mechanize::TestCase

  class P
    include Mechanize::Parser

    attr_accessor :filename
    attr_accessor :response
    attr_accessor :uri

    def initialize
      @uri = URI 'http://example'
    end
  end

  def setup
    super

    @parser = P.new
  end

  def test_extract_filename
    @parser.response = {}

    assert_equal 'index.html', @parser.extract_filename
  end

  def test_extract_filename_content_disposition
    @parser.uri = URI 'http://example/foo'

    @parser.response = {
      'content-disposition' => 'attachment; filename=genome.jpeg; modification-date="Wed, 12 Feb 1997 16:29:51 -0500"'
    }

    assert_equal 'genome.jpeg', @parser.extract_filename

    @parser.response = {
      'content-disposition' => 'filename=genome.jpeg; modification-date="Wed, 12 Feb 1997 16:29:51 -0500"'
    }

    assert_equal 'genome.jpeg', @parser.extract_filename

    @parser.response = {
      'content-disposition' => 'filename=genome.jpeg'
    }

    assert_equal 'genome.jpeg', @parser.extract_filename
  end

  def test_extract_filename_content_disposition_path
    @parser.uri = URI 'http://example'

    @parser.response = {
      'content-disposition' => 'attachment; filename=../genome.jpeg'
    }

    assert_equal 'example/genome.jpeg', @parser.extract_filename(true)

    @parser.response = {
      'content-disposition' => 'attachment; filename=foo/genome.jpeg'
    }

    assert_equal 'example/genome.jpeg', @parser.extract_filename(true)
  end

  def test_extract_filename_content_disposition_full_path
    @parser.uri = URI 'http://example/foo'

    @parser.response = {
      'content-disposition' => 'attachment; filename=genome.jpeg; modification-date="Wed, 12 Feb 1997 16:29:51 -0500"'
    }

    assert_equal 'example/genome.jpeg', @parser.extract_filename(true)

    @parser.response = {
      'content-disposition' => 'filename=genome.jpeg; modification-date="Wed, 12 Feb 1997 16:29:51 -0500"'
    }

    assert_equal 'example/genome.jpeg', @parser.extract_filename(true)

    @parser.response = {
      'content-disposition' => 'filename=genome.jpeg'
    }

    assert_equal 'example/genome.jpeg', @parser.extract_filename(true)
  end

  def test_extract_filename_content_disposition_bad
    @parser.uri = URI 'http://example/foo'

    @parser.response = {
      'content-disposition' => 'attachment;; filename=genome.jpeg'
    }

    assert_equal 'genome.jpeg', @parser.extract_filename
  end

  def test_extract_filename_uri
    @parser.response = {}
    @parser.uri = URI 'http://example/foo'

    assert_equal 'foo.html', @parser.extract_filename

    @parser.uri += '/foo.jpg'

    assert_equal 'foo.jpg', @parser.extract_filename
  end

  def test_extract_filename_uri_full_path
    @parser.response = {}
    @parser.uri = URI 'http://example/foo'

    assert_equal 'example/foo.html', @parser.extract_filename(true)

    @parser.uri += '/foo.jpg'

    assert_equal 'example/foo.jpg', @parser.extract_filename(true)
  end

  def test_extract_filename_host
    @parser.response = {}
    @parser.uri = URI 'http://example'

    assert_equal 'example/index.html', @parser.extract_filename(true)
  end

  def test_extract_filename_uri_query
    @parser.response = {}
    @parser.uri = URI 'http://example/?id=5'

    assert_equal 'index.html?id=5', @parser.extract_filename

    @parser.uri += '/foo.html?id=5'

    assert_equal 'foo.html?id=5', @parser.extract_filename
  end

  def test_extract_filename_uri_slash
    @parser.response = {}
    @parser.uri = URI 'http://example/foo/'

    assert_equal 'example/foo/index.html', @parser.extract_filename(true)

    @parser.uri += '/foo///'

    assert_equal 'example/foo/index.html', @parser.extract_filename(true)
  end

  def test_fill_header
    @parser.fill_header 'a' => 'b'

    expected = { 'a' => 'b' }

    assert_equal expected, @parser.response
  end

  def test_fill_header_nil
    @parser.fill_header nil

    assert_empty @parser.response
  end

end

