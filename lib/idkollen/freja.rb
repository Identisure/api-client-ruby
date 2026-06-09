# frozen_string_literal: true

module Idkollen
  module Freja
    class AuthRequest
      attr_reader :ssn, :callback_url, :min_registration_level, :org_number,
                  :request_address, :ref_id

      def initialize(ssn: nil, callback_url: nil, min_registration_level: nil,
                     org_number: nil, request_address: nil, ref_id: nil)
        @ssn = ssn; @callback_url = callback_url
        @min_registration_level = min_registration_level; @org_number = org_number
        @request_address = request_address; @ref_id = ref_id
      end

      def to_h
        {
          ssn: @ssn, callbackUrl: @callback_url,
          minRegistrationLevel: @min_registration_level, orgNumber: @org_number,
          requestAddress: @request_address, refId: @ref_id,
        }.compact
      end
    end

    class BackchannelAuthRequest
      attr_reader :ssn, :country, :callback_url, :min_registration_level,
                  :org_number, :request_address, :ref_id

      def initialize(ssn:, country:, callback_url: nil, min_registration_level: nil,
                     org_number: nil, request_address: nil, ref_id: nil)
        @ssn = ssn; @country = country; @callback_url = callback_url
        @min_registration_level = min_registration_level; @org_number = org_number
        @request_address = request_address; @ref_id = ref_id
      end

      def to_h
        {
          ssn: @ssn, country: @country, callbackUrl: @callback_url,
          minRegistrationLevel: @min_registration_level, orgNumber: @org_number,
          requestAddress: @request_address, refId: @ref_id,
        }.compact
      end
    end

    class SignRequest
      attr_reader :text, :ssn, :callback_url, :min_registration_level,
                  :org_number, :request_address, :ref_id

      def initialize(text:, ssn: nil, callback_url: nil, min_registration_level: nil,
                     org_number: nil, request_address: nil, ref_id: nil)
        @text = text; @ssn = ssn; @callback_url = callback_url
        @min_registration_level = min_registration_level; @org_number = org_number
        @request_address = request_address; @ref_id = ref_id
      end

      def to_h
        {
          text: @text, ssn: @ssn, callbackUrl: @callback_url,
          minRegistrationLevel: @min_registration_level, orgNumber: @org_number,
          requestAddress: @request_address, refId: @ref_id,
        }.compact
      end
    end

    class BackchannelSignRequest
      attr_reader :ssn, :country, :text, :callback_url, :min_registration_level,
                  :org_number, :request_address, :ref_id

      def initialize(ssn:, country:, text:, callback_url: nil, min_registration_level: nil,
                     org_number: nil, request_address: nil, ref_id: nil)
        @ssn = ssn; @country = country; @text = text; @callback_url = callback_url
        @min_registration_level = min_registration_level; @org_number = org_number
        @request_address = request_address; @ref_id = ref_id
      end

      def to_h
        {
          ssn: @ssn, country: @country, text: @text, callbackUrl: @callback_url,
          minRegistrationLevel: @min_registration_level, orgNumber: @org_number,
          requestAddress: @request_address, refId: @ref_id,
        }.compact
      end
    end

    class Pending
      attr_reader :id, :ref_id, :auto_start_token, :qr_data

      def initialize(id:, auto_start_token:, qr_data:, ref_id: nil)
        @id = id; @ref_id = ref_id
        @auto_start_token = auto_start_token; @qr_data = qr_data
      end

      def deconstruct_keys(_)
        { id: @id, ref_id: @ref_id, auto_start_token: @auto_start_token, qr_data: @qr_data }
      end

      def self.from_json(d)
        new(id: d['id'], ref_id: d['refId'],
            auto_start_token: d['autoStartToken'], qr_data: d['qrData'])
      end
    end

    class Completed
      attr_reader :id, :ref_id, :ssn, :country, :name, :given_name, :surname,
                  :address, :company_signatory_text

      def initialize(id:, ssn:, country:, name:, given_name:, surname:,
                     ref_id: nil, address: nil, company_signatory_text: nil)
        @id = id; @ref_id = ref_id; @ssn = ssn; @country = country
        @name = name; @given_name = given_name; @surname = surname
        @address = address; @company_signatory_text = company_signatory_text
      end

      def deconstruct_keys(_)
        { id: @id, ref_id: @ref_id, ssn: @ssn, country: @country,
          name: @name, given_name: @given_name, surname: @surname,
          address: @address, company_signatory_text: @company_signatory_text }
      end

      def self.from_json(d)
        new(
          id: d['id'], ref_id: d['refId'], ssn: d['ssn'], country: d['country'],
          name: d['name'], given_name: d['givenName'], surname: d['surname'],
          address: d['address'], company_signatory_text: d['companySignatoryText'],
        )
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
        else raise ArgumentError, "Unknown freja status: #{d['status']}"
        end
      end
    end

    class Endpoint
      def initialize(transport)
        @transport = transport
      end

      def auth(req)                  = Status.from_json(@transport.post('/v3/freja/auth', req.to_h))
      def backchannel_auth(req)      = Status.from_json(@transport.post('/v3/freja/backchannel/auth', req.to_h))
      def sign(req)                  = Status.from_json(@transport.post('/v3/freja/sign', req.to_h))
      def backchannel_sign(req)      = Status.from_json(@transport.post('/v3/freja/backchannel/sign', req.to_h))
      def auth_status(id)            = Status.from_json(@transport.get("/v3/freja/auth/#{id}"))
      def sign_status(id)            = Status.from_json(@transport.get("/v3/freja/sign/#{id}"))
      def cancel_auth(id)            = @transport.delete("/v3/freja/auth/#{id}")
      def cancel_sign(id)            = @transport.delete("/v3/freja/sign/#{id}")

      def age_verification(req)
        Idkollen::AgeVerification::Status.from_json(@transport.post('/v3/freja/age-verification', req.to_h))
      end

      def age_verification_status(id)
        Idkollen::AgeVerification::Status.from_json(@transport.get("/v3/freja/age-verification/#{id}"))
      end

      def cancel_age_verification(id) = @transport.delete("/v3/freja/age-verification/#{id}")

      def wait_for_auth(id, opts: PollOptions.new) = poll(opts) { auth_status(id) }
      def wait_for_sign(id, opts: PollOptions.new) = poll(opts) { sign_status(id) }

      def wait_for_age_verification(id, opts: PollOptions.new)
        poll_age(opts) { age_verification_status(id) }
      end

      private

      def poll(opts)
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
