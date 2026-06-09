# frozen_string_literal: true

require_relative 'test_helper'

class BankIdNoTest < Minitest::Test
  def setup
    @mock = MockAdapter.new
    @client = Idkollen::ClientBuilder.new('cid', 'sec').http_client(@mock.connection).build
  end

  def test_auth_pending
    @mock.enqueue(200, { 'status' => 'PENDING', 'id' => 'no1', 'url' => 'https://login' })
    result = @client.bank_id_no.auth(Idkollen::BankIdNo::AuthRequest.new(request_ssn: true))
    assert_kind_of Idkollen::BankIdNo::Pending, result
    assert_equal 'https://login', result.url
  end

  def test_auth_completed_with_signed_documents
    @mock.enqueue(200, {
      'status' => 'COMPLETED', 'id' => 'no1', 'ssn' => '01010100000',
      'name' => 'Ola Nordmann', 'givenName' => 'Ola', 'surname' => 'Nordmann',
      'signedDocuments' => [
        { 'id' => 'd1', 'hash' => 'h1' },
        { 'id' => 'd2', 'hash' => 'h2' },
      ],
    })
    result = @client.bank_id_no.auth_status('no1')
    assert_kind_of Idkollen::BankIdNo::Completed, result
    assert_equal 2, result.signed_documents.length
    assert_equal 'd1', result.signed_documents[0].id
  end
end
