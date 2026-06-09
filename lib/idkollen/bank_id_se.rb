# frozen_string_literal: true

module Idkollen
  module BankIdSe
    # --- Requests ---

    class AuthRequest
      attr_reader :ssn, :ip_address, :callback_url, :pin_required, :intent,
                  :org_number, :request_address, :ref_id

      def initialize(ssn: nil, ip_address: nil, callback_url: nil, pin_required: nil,
                     intent: nil, org_number: nil, request_address: nil, ref_id: nil)
        @ssn = ssn
        @ip_address = ip_address
        @callback_url = callback_url
        @pin_required = pin_required
        @intent = intent
        @org_number = org_number
        @request_address = request_address
        @ref_id = ref_id
      end

      def to_h
        {
          ssn: @ssn, ipAddress: @ip_address, callbackUrl: @callback_url,
          pinRequired: @pin_required, intent: @intent, orgNumber: @org_number,
          requestAddress: @request_address, refId: @ref_id,
        }.compact
      end
    end

    class PhoneAuthRequest
      attr_reader :ssn, :call_initiator, :callback_url, :pin_required, :intent,
                  :org_number, :request_address, :ref_id

      def initialize(ssn:, call_initiator:, callback_url: nil, pin_required: nil,
                     intent: nil, org_number: nil, request_address: nil, ref_id: nil)
        @ssn = ssn
        @call_initiator = call_initiator
        @callback_url = callback_url
        @pin_required = pin_required
        @intent = intent
        @org_number = org_number
        @request_address = request_address
        @ref_id = ref_id
      end

      def to_h
        {
          ssn: @ssn, callInitiator: @call_initiator, callbackUrl: @callback_url,
          pinRequired: @pin_required, intent: @intent, orgNumber: @org_number,
          requestAddress: @request_address, refId: @ref_id,
        }.compact
      end
    end

    class SignRequest
      attr_reader :text, :ssn, :ip_address, :callback_url, :pin_required, :digest,
                  :org_number, :request_address, :ref_id

      def initialize(text:, ssn: nil, ip_address: nil, callback_url: nil, pin_required: nil,
                     digest: nil, org_number: nil, request_address: nil, ref_id: nil)
        @text = text; @ssn = ssn; @ip_address = ip_address; @callback_url = callback_url
        @pin_required = pin_required; @digest = digest; @org_number = org_number
        @request_address = request_address; @ref_id = ref_id
      end

      def to_h
        {
          text: @text, ssn: @ssn, ipAddress: @ip_address, callbackUrl: @callback_url,
          pinRequired: @pin_required, digest: @digest, orgNumber: @org_number,
          requestAddress: @request_address, refId: @ref_id,
        }.compact
      end
    end

    class PhoneSignRequest
      attr_reader :ssn, :call_initiator, :text, :callback_url, :pin_required, :digest,
                  :org_number, :request_address, :ref_id

      def initialize(ssn:, call_initiator:, text:, callback_url: nil, pin_required: nil,
                     digest: nil, org_number: nil, request_address: nil, ref_id: nil)
        @ssn = ssn; @call_initiator = call_initiator; @text = text
        @callback_url = callback_url; @pin_required = pin_required; @digest = digest
        @org_number = org_number; @request_address = request_address; @ref_id = ref_id
      end

      def to_h
        {
          ssn: @ssn, callInitiator: @call_initiator, text: @text,
          callbackUrl: @callback_url, pinRequired: @pin_required, digest: @digest,
          orgNumber: @org_number, requestAddress: @request_address, refId: @ref_id,
        }.compact
      end
    end

    class VerifyRequest
      attr_reader :qr_code
      def initialize(qr_code:) = @qr_code = qr_code
      def to_h = { qrCode: @qr_code }
    end

    class VerifyResponse
      attr_reader :ssn, :name, :given_name, :surname, :age, :verified_at

      def initialize(ssn:, name:, given_name:, surname:, age: nil, verified_at: nil)
        @ssn = ssn; @name = name; @given_name = given_name; @surname = surname
        @age = age; @verified_at = verified_at
      end

      def deconstruct_keys(_)
        { ssn: @ssn, name: @name, given_name: @given_name, surname: @surname,
          age: @age, verified_at: @verified_at }
      end

      def self.from_json(d)
        new(ssn: d['ssn'], name: d['name'], given_name: d['givenName'],
            surname: d['surname'], age: d['age'], verified_at: d['verifiedAt'])
      end
    end

    # --- Status variants ---

    class Pending
      attr_reader :id, :ref_id, :auto_start_token, :qr_start_token, :qr_start_secret, :hint_code

      def initialize(id:, ref_id: nil, auto_start_token: nil, qr_start_token: nil,
                     qr_start_secret: nil, hint_code: nil)
        @id = id; @ref_id = ref_id; @auto_start_token = auto_start_token
        @qr_start_token = qr_start_token; @qr_start_secret = qr_start_secret
        @hint_code = hint_code
      end

      def deconstruct_keys(_)
        { id: @id, ref_id: @ref_id, auto_start_token: @auto_start_token,
          qr_start_token: @qr_start_token, qr_start_secret: @qr_start_secret,
          hint_code: @hint_code }
      end

      def self.from_json(d)
        new(id: d['id'], ref_id: d['refId'], auto_start_token: d['autoStartToken'],
            qr_start_token: d['qrStartToken'], qr_start_secret: d['qrStartSecret'],
            hint_code: d['hintCode'])
      end
    end

    class PendingPhone
      attr_reader :id, :ref_id, :hint_code

      def initialize(id:, ref_id: nil, hint_code: nil)
        @id = id; @ref_id = ref_id; @hint_code = hint_code
      end

      def deconstruct_keys(_) = { id: @id, ref_id: @ref_id, hint_code: @hint_code }

      def self.from_json(d)
        new(id: d['id'], ref_id: d['refId'], hint_code: d['hintCode'])
      end
    end

    class Completed
      attr_reader :id, :ref_id, :ssn, :name, :given_name, :surname,
                  :cert_start_date, :address, :company_signatory_text

      def initialize(id:, ssn:, name:, given_name:, surname:,
                     ref_id: nil, cert_start_date: nil, address: nil, company_signatory_text: nil)
        @id = id; @ref_id = ref_id; @ssn = ssn; @name = name
        @given_name = given_name; @surname = surname
        @cert_start_date = cert_start_date; @address = address
        @company_signatory_text = company_signatory_text
      end

      def deconstruct_keys(_)
        { id: @id, ref_id: @ref_id, ssn: @ssn, name: @name, given_name: @given_name,
          surname: @surname, cert_start_date: @cert_start_date, address: @address,
          company_signatory_text: @company_signatory_text }
      end

      def self.from_json(d)
        new(id: d['id'], ref_id: d['refId'], ssn: d['ssn'], name: d['name'],
            given_name: d['givenName'], surname: d['surname'],
            cert_start_date: d['certStartDate'], address: d['address'],
            company_signatory_text: d['companySignatoryText'])
      end
    end

    class Failed
      attr_reader :id, :ref_id, :error

      def initialize(id:, error:, ref_id: nil)
        @id = id; @ref_id = ref_id; @error = error
      end

      def deconstruct_keys(_) = { id: @id, ref_id: @ref_id, error: @error }

      def self.from_json(d) = new(id: d['id'], ref_id: d['refId'], error: d['error'])
    end

    module Status
      def self.from_json(d)
        case d['status']
        when 'PENDING'   then Pending.from_json(d)
        when 'COMPLETED' then Completed.from_json(d)
        when 'FAILED'    then Failed.from_json(d)
        else raise ArgumentError, "Unknown bankid-se status: #{d['status']}"
        end
      end
    end

    module PhoneStatus
      def self.from_json(d)
        case d['status']
        when 'PENDING'   then PendingPhone.from_json(d)
        when 'COMPLETED' then Completed.from_json(d)
        when 'FAILED'    then Failed.from_json(d)
        else raise ArgumentError, "Unknown bankid-se phone status: #{d['status']}"
        end
      end
    end

    # --- Endpoint ---

    class Endpoint
      def initialize(transport)
        @transport = transport
      end

      def auth(req)        = Status.from_json(@transport.post('/v3/bankid-se/auth', req.to_h))
      def phone_auth(req)  = PhoneStatus.from_json(@transport.post('/v3/bankid-se/phone/auth', req.to_h))
      def sign(req)        = Status.from_json(@transport.post('/v3/bankid-se/sign', req.to_h))
      def phone_sign(req)  = PhoneStatus.from_json(@transport.post('/v3/bankid-se/phone/sign', req.to_h))
      def verify(req)      = VerifyResponse.from_json(@transport.post('/v3/bankid-se/verify', req.to_h))

      def age_verification(req)
        Idkollen::AgeVerification::Status.from_json(@transport.post('/v3/bankid-se/age-verification', req.to_h))
      end

      def auth_status(id) = Status.from_json(@transport.get("/v3/bankid-se/auth/#{id}"))
      def sign_status(id) = Status.from_json(@transport.get("/v3/bankid-se/sign/#{id}"))

      def age_verification_status(id)
        Idkollen::AgeVerification::Status.from_json(@transport.get("/v3/bankid-se/age-verification/#{id}"))
      end

      def cancel_auth(id)             = @transport.delete("/v3/bankid-se/auth/#{id}")
      def cancel_sign(id)             = @transport.delete("/v3/bankid-se/sign/#{id}")
      def cancel_age_verification(id) = @transport.delete("/v3/bankid-se/age-verification/#{id}")

      def wait_for_auth(id, opts: PollOptions.new)
        poll_status(opts) { auth_status(id) }
      end

      def wait_for_sign(id, opts: PollOptions.new)
        poll_status(opts) { sign_status(id) }
      end

      def wait_for_age_verification(id, opts: PollOptions.new)
        poll_age(opts) { age_verification_status(id) }
      end

      private

      def poll_status(opts)
        deadline = Time.now + opts.timeout
        loop do
          status = yield
          return status unless status.is_a?(Pending)
          raise WaitError.new(timeout: true) if Time.now >= deadline
          sleep opts.interval
        end
      end

      def poll_age(opts)
        deadline = Time.now + opts.timeout
        loop do
          status = yield
          return status unless status.is_a?(Idkollen::AgeVerification::Pending)
          raise WaitError.new(timeout: true) if Time.now >= deadline
          sleep opts.interval
        end
      end
    end
  end
end
