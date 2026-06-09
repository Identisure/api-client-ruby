# frozen_string_literal: true

require_relative 'test_helper'

class FrejaTest < Minitest::Test
  def setup
    @mock = MockAdapter.new
    @client = Idkollen::ClientBuilder.new('cid', 'sec').http_client(@mock.connection).build
  end

  def test_auth_pending
    @mock.enqueue(200, { 'status' => 'PENDING', 'id' => 'f1', 'autoStartToken' => 'tok', 'qrData' => 'qr' })
    result = @client.freja.auth(Idkollen::Freja::AuthRequest.new)
    assert_kind_of Idkollen::Freja::Pending, result
    assert_equal 'qr', result.qr_data
  end

  def test_auth_completed
    @mock.enqueue(200, {
      'status' => 'COMPLETED', 'id' => 'f2', 'ssn' => '19900101-1234',
      'country' => 'SE', 'name' => 'Anna Svensson',
      'givenName' => 'Anna', 'surname' => 'Svensson',
    })
    result = @client.freja.auth_status('f2')
    assert_kind_of Idkollen::Freja::Completed, result
    assert_equal 'SE', result.country
  end
end
