# frozen_string_literal: true

require_relative 'test_helper'
require 'json'

class FtnTest < Minitest::Test
  def setup
    @mock = MockAdapter.new
    @client = Idkollen::ClientBuilder.new('cid', 'sec').http_client(@mock.connection).build
  end

  def test_auth_pending
    @mock.enqueue(200, { 'status' => 'PENDING', 'id' => 'f1', 'url' => 'https://login' })
    result = @client.ftn.auth(Idkollen::Ftn::AuthRequest.new)
    assert_kind_of Idkollen::Ftn::Pending, result
    assert_equal 'https://login', result.url
  end

  def test_age_verification_completed
    @mock.enqueue(200, { 'status' => 'COMPLETED', 'id' => 'av1', 'ageVerified' => true })
    result = @client.ftn.age_verification(Idkollen::AgeVerification::Request.new(min_age: 18))
    assert_kind_of Idkollen::AgeVerification::Completed, result
    assert_equal true, result.age_verified
  end
end
