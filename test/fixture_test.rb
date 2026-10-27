# frozen_string_literal: true

require_relative 'test_helper'
require 'json'

class FixtureTest < Minitest::Test
  FIXTURES = File.expand_path('../../fixtures', __dir__)
  FAST_POLL = Identisure::PollOptions.new(interval: 0.001)
  AUTH_HEADER = "Basic #{['cid:sec'].pack('m0')}".freeze

  Flow = Struct.new(:dir, :segment, :mod, :start_auth, :start_sign)

  FLOWS = [
    Flow.new('bankid_se', 'bankid-se', Identisure::BankIdSe,
             ->(c) { c.bank_id_se.auth(Identisure::BankIdSe::AuthRequest.new) },
             ->(c) { c.bank_id_se.sign(Identisure::BankIdSe::SignRequest.new(text: 'Sign this')) }),
    Flow.new('bankid_no', 'bankid-no', Identisure::BankIdNo,
             ->(c) { c.bank_id_no.auth(Identisure::BankIdNo::AuthRequest.new) },
             ->(c) { c.bank_id_no.sign(Identisure::BankIdNo::SignRequest.new(text: 'Sign this')) }),
    Flow.new('freja', 'freja', Identisure::Freja,
             ->(c) { c.freja.auth(Identisure::Freja::AuthRequest.new) },
             ->(c) { c.freja.sign(Identisure::Freja::SignRequest.new(text: 'Sign this')) }),
    Flow.new('mitid', 'mitid', Identisure::MitId,
             ->(c) { c.mit_id.auth(Identisure::MitId::AuthRequest.new) },
             ->(c) { c.mit_id.sign(Identisure::MitId::SignRequest.new(text: 'Sign this')) }),
    Flow.new('ftn', 'ftn', Identisure::Ftn,
             ->(c) { c.ftn.auth(Identisure::Ftn::AuthRequest.new) }, nil),
    Flow.new('vipps', 'vipps', Identisure::Vipps,
             ->(c) { c.vipps.auth(Identisure::Vipps::AuthRequest.new) }, nil),
  ].freeze

  def setup
    @mock = MockAdapter.new
    @client = Identisure::ClientBuilder.new('cid', 'sec').base_url('https://x.test').http_client(@mock.connection).build
  end

  FLOWS.each do |flow|
    define_method("test_#{flow.dir}_auth_completes") do
      id = enqueue_flow("#{flow.dir}/auth_pending.json", "#{flow.dir}/auth_completed.json")
      endpoint = endpoint_for(flow)

      pending = flow.start_auth.call(@client)

      assert_kind_of flow.mod::Pending, pending
      assert_matches fixture("#{flow.dir}/auth_pending.json"), pending

      result = endpoint.wait_for_auth(id, opts: FAST_POLL)

      assert_kind_of flow.mod::Completed, result
      assert_matches fixture("#{flow.dir}/auth_completed.json"), result
      assert_requests [['post', "/v3/#{flow.segment}/auth"],
                       ['get', "/v3/#{flow.segment}/auth/#{id}"],
                       ['get', "/v3/#{flow.segment}/auth/#{id}"]]
    end

    define_method("test_#{flow.dir}_auth_fails") do
      id = enqueue_terminal("#{flow.dir}/auth_pending.json", "#{flow.dir}/auth_failed.json")
      flow.start_auth.call(@client)

      result = endpoint_for(flow).wait_for_auth(id, opts: FAST_POLL)

      assert_kind_of flow.mod::Failed, result
      assert_matches fixture("#{flow.dir}/auth_failed.json"), result
      assert_equal 'CANCELLED', result.error
    end

    define_method("test_#{flow.dir}_auth_unknown_status") do
      id = enqueue_terminal("#{flow.dir}/auth_pending.json", "#{flow.dir}/auth_unknown.json")
      flow.start_auth.call(@client)

      result = endpoint_for(flow).wait_for_auth(id, opts: FAST_POLL)

      assert_kind_of flow.mod::Unknown, result
      assert_equal 'SOMETHING_NEW', result.status
    end

    next unless flow.start_sign

    define_method("test_#{flow.dir}_sign_completes") do
      id = enqueue_flow("#{flow.dir}/auth_pending.json", "#{flow.dir}/sign_completed.json")

      assert_kind_of flow.mod::Pending, flow.start_sign.call(@client)

      result = endpoint_for(flow).wait_for_sign(id, opts: FAST_POLL)

      assert_kind_of flow.mod::Completed, result
      assert_matches fixture("#{flow.dir}/sign_completed.json"), result
      assert_requests [['post', "/v3/#{flow.segment}/sign"],
                       ['get', "/v3/#{flow.segment}/sign/#{id}"],
                       ['get', "/v3/#{flow.segment}/sign/#{id}"]]
    end
  end

  def test_bank_id_se_phone_auth_completes
    id = fixture('bankid_se/phone_auth_pending.json')['id']
    @mock.enqueue(201, raw('bankid_se/phone_auth_pending.json'))
    @mock.enqueue(200, raw('bankid_se/auth_completed.json'))

    req = Identisure::BankIdSe::PhoneAuthRequest.new(ssn: '199001011239', call_initiator: 'USER')
    pending = @client.bank_id_se.phone_auth(req)

    assert_kind_of Identisure::BankIdSe::PendingPhone, pending
    assert_equal id, pending.id
    assert_nil pending.hint_code

    result = @client.bank_id_se.wait_for_auth(id, opts: FAST_POLL)

    assert_kind_of Identisure::BankIdSe::Completed, result
    assert_matches fixture('bankid_se/auth_completed.json'), result
    assert_requests [['post', '/v3/bankid-se/phone/auth'], ['get', "/v3/bankid-se/auth/#{id}"]]
  end

  def test_bank_id_se_verify
    @mock.enqueue(200, raw('bankid_se/verify.json'))

    result = @client.bank_id_se.verify(Identisure::BankIdSe::VerifyRequest.new(qr_code: 'bankidqr.1.2.3'))

    assert_matches fixture('bankid_se/verify.json'), result
    assert_requests [['post', '/v3/bankid-se/verify']]
  end

  def test_age_verification_completes
    id = enqueue_flow('age_verification/pending.json', 'age_verification/completed.json')

    pending = @client.bank_id_se.age_verification(Identisure::AgeVerification::Request.new(min_age: 18))

    assert_kind_of Identisure::AgeVerification::Pending, pending
    assert_matches fixture('age_verification/pending.json'), pending

    result = @client.bank_id_se.wait_for_age_verification(id, opts: FAST_POLL)

    assert_kind_of Identisure::AgeVerification::Completed, result
    assert_matches fixture('age_verification/completed.json'), result
    assert_requests [['post', '/v3/bankid-se/age-verification'],
                     ['get', "/v3/bankid-se/age-verification/#{id}"],
                     ['get', "/v3/bankid-se/age-verification/#{id}"]]
  end

  def test_age_verification_fails
    id = enqueue_terminal('age_verification/pending.json', 'age_verification/failed.json')
    @client.bank_id_se.age_verification(Identisure::AgeVerification::Request.new(min_age: 18))

    result = @client.bank_id_se.wait_for_age_verification(id, opts: FAST_POLL)

    assert_kind_of Identisure::AgeVerification::Failed, result
    assert_matches fixture('age_verification/failed.json'), result
  end

  def test_age_verification_unknown_status
    id = enqueue_terminal('age_verification/pending.json', 'age_verification/unknown.json')
    @client.bank_id_se.age_verification(Identisure::AgeVerification::Request.new(min_age: 18))

    result = @client.bank_id_se.wait_for_age_verification(id, opts: FAST_POLL)

    assert_kind_of Identisure::AgeVerification::Unknown, result
    assert_equal 'SOMETHING_NEW', result.status
  end

  def test_document_upload
    @mock.enqueue(201, raw('document/upload.json'))

    result = @client.document.upload('%PDF-1.7', 'contract.pdf')

    assert_matches fixture('document/upload.json'), result
    assert_requests [['post', '/v3/document']]
  end

  def test_error_response
    @mock.enqueue(400, raw('error.json'))

    err = assert_raises(Identisure::IdentisureError) { @client.ftn.auth(Identisure::Ftn::AuthRequest.new) }
    assert_equal 400, err.status_code
    assert_includes err.message, 'Invalid request'
  end

  private

  def raw(path) = File.read(File.join(FIXTURES, path))
  def fixture(path) = JSON.parse(raw(path))

  def endpoint_for(flow)
    { 'bankid_se' => :bank_id_se, 'bankid_no' => :bank_id_no, 'freja' => :freja,
      'mitid' => :mit_id, 'ftn' => :ftn, 'vipps' => :vipps }.fetch(flow.dir).then { @client.public_send(_1) }
  end

  # Queues start (201), one pending poll and the terminal poll. Returns the session id.
  def enqueue_flow(pending, terminal)
    @mock.enqueue(201, raw(pending))
    @mock.enqueue(200, raw(pending))
    @mock.enqueue(200, raw(terminal))
    fixture(pending)['id']
  end

  # Queues start (201) and the terminal poll. Returns the session id.
  def enqueue_terminal(pending, terminal)
    @mock.enqueue(201, raw(pending))
    @mock.enqueue(200, raw(terminal))
    fixture(pending)['id']
  end

  def assert_requests(expected)
    assert_equal(expected, @mock.requests.map { [_1[:method].to_s, _1[:path]] })
    @mock.requests.each { assert_equal AUTH_HEADER, _1[:headers]['Authorization'] }
  end

  # Compares fixture JSON against the decoded object, mapping camelCase keys to snake_case readers.
  # `hash` is exposed as `document_hash` because `hash` would shadow Object#hash.
  def assert_matches(expected, actual, path = '')
    case expected
    when Hash
      expected.each do |key, value|
        next if key == 'status' && path.empty?

        reader = key == 'hash' ? 'document_hash' : key.gsub(/([A-Z])/) { "_#{Regexp.last_match(1).downcase}" }

        assert_respond_to actual, reader, "#{path}.#{key}"
        assert_matches value, actual.public_send(reader), "#{path}.#{key}"
      end
    when Array
      assert_equal expected.length, actual.length, path
      expected.zip(actual).each { |e, a| assert_matches e, a, path }
    when nil

      assert_nil actual, path
    else
      assert_equal expected, actual, path
    end
  end
end
