# frozen_string_literal: true

require_relative 'test_helper'

class CallbackTest < Minitest::Test
  SECRET = 'test-secret'
  BODY = '{"id":"abc","status":"COMPLETED"}'
  SIGNATURE = 'Ag2m3etnW31OP585jvcrvOupK7Vgsrzcq17KxKvkIOs='

  def test_valid_signature
    assert Identisure.verify_callback_signature(BODY, SIGNATURE, SECRET)
  end

  def test_tampered_body
    refute Identisure.verify_callback_signature("#{BODY} ", SIGNATURE, SECRET)
  end

  def test_malformed_signature
    refute Identisure.verify_callback_signature(BODY, 'not base64!', SECRET)
  end
end
