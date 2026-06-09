# frozen_string_literal: true

require_relative 'test_helper'

class VippsTest < Minitest::Test
  def setup
    @mock = MockAdapter.new
    @client = Idkollen::ClientBuilder.new('cid', 'sec').http_client(@mock.connection).build
  end

  def test_auth_pending
    @mock.enqueue(200, { 'status' => 'PENDING', 'id' => 'v1', 'url' => 'https://login' })
    result = @client.vipps.auth(Idkollen::Vipps::AuthRequest.new)
    assert_kind_of Idkollen::Vipps::Pending, result
    assert_equal 'v1', result.id
    assert_equal 'https://login', result.url
  end

  def test_backchannel_auth_sends_phone
    @mock.enqueue(200, { 'status' => 'PENDING', 'id' => 'v2' })
    @client.vipps.backchannel_auth(Idkollen::Vipps::BackchannelAuthRequest.new(phone: '+4712345678'))
    assert_equal '+4712345678', JSON.parse(@mock.last_request_body)['phone']
  end
end
