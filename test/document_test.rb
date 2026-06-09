# frozen_string_literal: true

require_relative 'test_helper'

class DocumentTest < Minitest::Test
  def setup
    @mock = MockAdapter.new
    @client = Idkollen::ClientBuilder.new('cid', 'sec').http_client(@mock.connection).build
  end

  def test_upload
    @mock.enqueue(200, { 'id' => 'doc1', 'hash' => 'h1' })
    result = @client.document.upload('PDF-DATA', 'contract.pdf')
    assert_equal 'doc1', result.id
    assert_equal 'h1', result.hash

    req = @mock.last_request
    assert_equal :post, req[:method]
    assert_match %r{\Amultipart/form-data}, req[:headers]['Content-Type']
  end

  def test_download_returns_raw_bytes
    @mock.enqueue(200, "\x25PDF-binary-bytes")
    result = @client.document.download('doc1')
    assert_equal "\x25PDF-binary-bytes", result
  end

  def test_delete
    @mock.enqueue(204, '')
    @client.document.delete('doc1')
    assert_equal :delete, @mock.last_request[:method]
    assert_equal '/document/doc1', @mock.last_request[:path]
  end
end
