# frozen_string_literal: true

require_relative 'test_helper'

class ClientTest < Minitest::Test
  def test_builder_produces_client
    client = Idkollen::ClientBuilder.new('id', 'secret')
                                     .environment(Idkollen::Environment::STAGING)
                                     .build
    assert_kind_of Idkollen::Client, client
  end

  def test_transport_attaches_basic_auth_and_user_agent
    mock = MockAdapter.new
    mock.enqueue(200, { 'ok' => true })

    client = Idkollen::ClientBuilder.new('cid', 'sec')
                                     .http_client(mock.connection)
                                     .build
    # Use transport via a get on an arbitrary path through a stub endpoint.
    transport = client.instance_variable_get(:@transport)
    transport.get('/v3/ping')

    req = mock.last_request
    auth_header = req[:headers]['Authorization'] || req[:headers]['authorization']
    expected = 'Basic ' + ['cid:sec'].pack('m0')
    assert_equal expected, auth_header
    assert_match %r{idkollen-client-ruby/}, req[:headers]['User-Agent']
    assert_equal '/v3/ping', req[:path]
  end

  def test_non_2xx_raises_idkollen_error
    mock = MockAdapter.new
    mock.enqueue(400, { 'message' => 'bad request' })
    client = Idkollen::ClientBuilder.new('a', 'b').http_client(mock.connection).build
    transport = client.instance_variable_get(:@transport)

    err = assert_raises(Idkollen::IdkollenError) { transport.post('/v3/things', { a: 1 }) }
    assert_equal 400, err.status_code
    assert_includes err.message, 'bad request'
  end
end
