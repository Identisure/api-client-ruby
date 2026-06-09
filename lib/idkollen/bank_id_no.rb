# frozen_string_literal: true

module Idkollen
  module BankIdNo
    class AuthRequest
      attr_reader :redirect_url, :request_ssn, :request_phone, :request_email,
                  :request_address, :ref_id, :app_callback_uri

      def initialize(redirect_url: nil, request_ssn: nil, request_phone: nil,
                     request_email: nil, request_address: nil, ref_id: nil,
                     app_callback_uri: nil)
        @redirect_url = redirect_url; @request_ssn = request_ssn
        @request_phone = request_phone; @request_email = request_email
        @request_address = request_address; @ref_id = ref_id
        @app_callback_uri = app_callback_uri
      end

      def to_h
        {
          redirectUrl: @redirect_url, requestSsn: @request_ssn,
          requestPhone: @request_phone, requestEmail: @request_email,
          requestAddress: @request_address, refId: @ref_id,
          appCallbackUri: @app_callback_uri,
        }.compact
      end
    end

    class BackchannelAuthRequest
      attr_reader :ssn, :callback_url, :ref_id

      def initialize(ssn:, callback_url: nil, ref_id: nil)
        @ssn = ssn; @callback_url = callback_url; @ref_id = ref_id
      end

      def to_h
        { ssn: @ssn, callbackUrl: @callback_url, refId: @ref_id }.compact
      end
    end

    class SignRequest
      attr_reader :redirect_url, :text, :documents, :request_ssn, :request_phone,
                  :request_email, :request_address, :ref_id

      def initialize(redirect_url: nil, text: nil, documents: nil, request_ssn: nil,
                     request_phone: nil, request_email: nil, request_address: nil,
                     ref_id: nil)
        @redirect_url = redirect_url; @text = text; @documents = documents
        @request_ssn = request_ssn; @request_phone = request_phone
        @request_email = request_email; @request_address = request_address
        @ref_id = ref_id
      end

      def to_h
        {
          redirectUrl: @redirect_url, text: @text, documents: @documents,
          requestSsn: @request_ssn, requestPhone: @request_phone,
          requestEmail: @request_email, requestAddress: @request_address,
          refId: @ref_id,
        }.compact
      end
    end

    class SignResult
      attr_reader :end_user, :merchant, :hash
      def initialize(end_user:, merchant:, hash:)
        @end_user = end_user; @merchant = merchant; @hash = hash
      end
      def deconstruct_keys(_) = { end_user: @end_user, merchant: @merchant, hash: @hash }
      def self.from_json(d) = new(end_user: d['endUser'], merchant: d['merchant'], hash: d['hash'])
    end

    class SignedDocument
      attr_reader :id, :hash
      def initialize(id:, hash:)
        @id = id; @hash = hash
      end
      def deconstruct_keys(_) = { id: @id, hash: @hash }
      def self.from_json(d) = new(id: d['id'], hash: d['hash'])
    end

    class Pending
      attr_reader :id, :ref_id, :url, :binding_message
      def initialize(id:, ref_id: nil, url: nil, binding_message: nil)
        @id = id; @ref_id = ref_id; @url = url; @binding_message = binding_message
      end
      def deconstruct_keys(_) = { id: @id, ref_id: @ref_id, url: @url, binding_message: @binding_message }
      def self.from_json(d)
        new(id: d['id'], ref_id: d['refId'], url: d['url'], binding_message: d['bindingMessage'])
      end
    end

    class Completed
      attr_reader :id, :ref_id, :ssn, :name, :given_name, :surname,
                  :phone, :email, :address, :birth_date, :pid, :bank_id,
                  :sign_result, :signed_documents

      def initialize(id:, ssn:, name:, given_name:, surname:, ref_id: nil,
                     phone: nil, email: nil, address: nil, birth_date: nil,
                     pid: nil, bank_id: nil, sign_result: nil, signed_documents: nil)
        @id = id; @ref_id = ref_id; @ssn = ssn; @name = name
        @given_name = given_name; @surname = surname; @phone = phone
        @email = email; @address = address; @birth_date = birth_date
        @pid = pid; @bank_id = bank_id; @sign_result = sign_result
        @signed_documents = signed_documents
      end

      def deconstruct_keys(_)
        { id: @id, ref_id: @ref_id, ssn: @ssn, name: @name, given_name: @given_name,
          surname: @surname, phone: @phone, email: @email, address: @address,
          birth_date: @birth_date, pid: @pid, bank_id: @bank_id,
          sign_result: @sign_result, signed_documents: @signed_documents }
      end

      def self.from_json(d)
        new(
          id: d['id'], ref_id: d['refId'], ssn: d['ssn'], name: d['name'],
          given_name: d['givenName'], surname: d['surname'], phone: d['phone'],
          email: d['email'], address: d['address'], birth_date: d['birthDate'],
          pid: d['pid'], bank_id: d['bankId'],
          sign_result: d['signResult'] ? SignResult.from_json(d['signResult']) : nil,
          signed_documents: d['signedDocuments']&.map { SignedDocument.from_json(_1) },
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
        else raise ArgumentError, "Unknown bankid-no status: #{d['status']}"
        end
      end
    end

    class Endpoint
      def initialize(transport)
        @transport = transport
      end

      def auth(req)              = Status.from_json(@transport.post('/v3/bankid-no/auth', req.to_h))
      def backchannel_auth(req)  = Status.from_json(@transport.post('/v3/bankid-no/backchannel/auth', req.to_h))
      def sign(req)              = Status.from_json(@transport.post('/v3/bankid-no/sign', req.to_h))
      def auth_status(id)        = Status.from_json(@transport.get("/v3/bankid-no/auth/#{id}"))
      def sign_status(id)        = Status.from_json(@transport.get("/v3/bankid-no/sign/#{id}"))
      def cancel_auth(id)        = @transport.delete("/v3/bankid-no/auth/#{id}")
      def cancel_sign(id)        = @transport.delete("/v3/bankid-no/sign/#{id}")

      def age_verification(req)
        Idkollen::AgeVerification::Status.from_json(@transport.post('/v3/bankid-no/age-verification', req.to_h))
      end

      def age_verification_status(id)
        Idkollen::AgeVerification::Status.from_json(@transport.get("/v3/bankid-no/age-verification/#{id}"))
      end

      def cancel_age_verification(id) = @transport.delete("/v3/bankid-no/age-verification/#{id}")

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
