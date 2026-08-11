# frozen_string_literal: true

require 'openssl'

module Idkollen
  # Verifies the X-Signature-SHA256 header of a callback request. Pass the raw request body as
  # received, before parsing it.
  def self.verify_callback_signature(body, signature, secret)
    expected = OpenSSL::HMAC.digest('SHA256', secret, body)
    actual = signature.unpack1('m0')
    actual.bytesize == expected.bytesize && OpenSSL.fixed_length_secure_compare(actual, expected)
  rescue ArgumentError
    false
  end
end
