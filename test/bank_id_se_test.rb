# frozen_string_literal: true

require_relative 'test_helper'
require 'json'

class BankIdSeTest < Minitest::Test
  def setup
    @mock = MockAdapter.new
    @client = Idkollen::ClientBuilder.new('cid', 'sec').http_client(@mock.connection).build
  end

  def test_auth_pending
    @mock.enqueue(200, { 'status' => 'PENDING', 'id' => 'abc', 'autoStartToken' => 'tok' })
    result = @client.bank_id_se.auth(Idkollen::BankIdSe::AuthRequest.new(ssn: '199001011234'))
    assert_kind_of Idkollen::BankIdSe::Pending, result
    assert_equal 'abc', result.id
    assert_equal 'tok', result.auto_start_token

    body = JSON.parse(@mock.last_request_body)
    assert_equal '199001011234', body['ssn']
  end

  def test_auth_completed
    @mock.enqueue(200, {
      'status' => 'COMPLETED', 'id' => 'abc', 'ssn' => '199001011234',
      'name' => 'Test User', 'givenName' => 'Test', 'surname' => 'User',
    })
    result = @client.bank_id_se.auth(Idkollen::BankIdSe::AuthRequest.new)
    assert_kind_of Idkollen::BankIdSe::Completed, result
    assert_equal 'Test User', result.name
  end

  def test_auth_failed
    @mock.enqueue(200, { 'status' => 'FAILED', 'id' => 'abc', 'error' => 'userCancel' })
    result = @client.bank_id_se.auth(Idkollen::BankIdSe::AuthRequest.new)
    assert_kind_of Idkollen::BankIdSe::Failed, result
    assert_equal 'userCancel', result.error
  end

  def test_phone_auth_pending
    @mock.enqueue(200, { 'status' => 'PENDING', 'id' => 'abc', 'hintCode' => 'outstandingTransaction' })
    result = @client.bank_id_se.phone_auth(
      Idkollen::BankIdSe::PhoneAuthRequest.new(ssn: '199001011234', call_initiator: 'user'),
    )
    assert_kind_of Idkollen::BankIdSe::PendingPhone, result
  end

  def test_verify
    @mock.enqueue(200, {
      'ssn' => '199001011234', 'name' => 'Test User', 'givenName' => 'Test',
      'surname' => 'User', 'age' => 34, 'verifiedAt' => '2026-06-08T10:00:00Z',
    })
    result = @client.bank_id_se.verify(Idkollen::BankIdSe::VerifyRequest.new(qr_code: 'qr'))
    assert_equal 34, result.age
  end

  def test_cancel_auth_sends_delete
    @mock.enqueue(204, '')
    @client.bank_id_se.cancel_auth('xyz')
    req = @mock.last_request
    assert_equal :delete, req[:method]
    assert_equal '/v3/bankid-se/auth/xyz', req[:path]
  end
end
