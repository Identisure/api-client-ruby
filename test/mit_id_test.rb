# frozen_string_literal: true

require_relative 'test_helper'

class MitIdTest < Minitest::Test
  def setup
    @mock = MockAdapter.new
    @client = Idkollen::ClientBuilder.new('cid', 'sec').http_client(@mock.connection).build
  end

  def test_auth_pending
    @mock.enqueue(200, { 'status' => 'PENDING', 'id' => 'm1', 'url' => 'https://mitid.login' })
    result = @client.mit_id.auth(Idkollen::MitId::AuthRequest.new)
    assert_kind_of Idkollen::MitId::Pending, result
    assert_equal 'https://mitid.login', result.url
  end

  def test_sign_completed_with_sign_result
    @mock.enqueue(200, {
      'status' => 'COMPLETED', 'id' => 'm1', 'ssn' => '0101010000',
      'name' => 'Hans', 'givenName' => 'Hans', 'surname' => 'H',
      'signResult' => { 'checksum' => 'abc123' },
    })
    result = @client.mit_id.sign_status('m1')
    assert_kind_of Idkollen::MitId::Completed, result
    assert_kind_of Idkollen::MitId::SignResult, result.sign_result
    assert_equal 'abc123', result.sign_result.checksum
  end
end
