# frozen_string_literal: true

module Idkollen
  module Vipps
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
      attr_reader :phone, :request_ssn, :request_email, :request_address,
                  :callback_url, :ref_id

      def initialize(phone:, request_ssn: nil, request_email: nil,
                     request_address: nil, callback_url: nil, ref_id: nil)
        @phone = phone; @request_ssn = request_ssn
        @request_email = request_email; @request_address = request_address
        @callback_url = callback_url; @ref_id = ref_id
      end

      def to_h
        {
          phone: @phone, requestSsn: @request_ssn,
          requestEmail: @request_email, requestAddress: @request_address,
          callbackUrl: @callback_url, refId: @ref_id,
        }.compact
      end
    end

    class Pending
      attr_reader :id, :ref_id, :url

      def initialize(id:, ref_id: nil, url: nil)
        @id = id; @ref_id = ref_id; @url = url
      end

      def deconstruct_keys(_) = { id: @id, ref_id: @ref_id, url: @url }

      def self.from_json(d) = new(id: d['id'], ref_id: d['refId'], url: d['url'])
    end

    class Completed
      attr_reader :id, :ref_id, :ssn, :name, :given_name, :surname,
                  :phone, :email, :address, :birth_date, :pid, :bank_id

      def initialize(id:, ssn:, name:, given_name:, surname:, ref_id: nil,
                     phone: nil, email: nil, address: nil, birth_date: nil,
                     pid: nil, bank_id: nil)
        @id = id; @ref_id = ref_id; @ssn = ssn; @name = name
        @given_name = given_name; @surname = surname; @phone = phone
        @email = email; @address = address; @birth_date = birth_date
        @pid = pid; @bank_id = bank_id
      end

      def deconstruct_keys(_)
        { id: @id, ref_id: @ref_id, ssn: @ssn, name: @name,
          given_name: @given_name, surname: @surname, phone: @phone,
          email: @email, address: @address, birth_date: @birth_date,
          pid: @pid, bank_id: @bank_id }
      end

      def self.from_json(d)
        new(
          id: d['id'], ref_id: d['refId'], ssn: d['ssn'], name: d['name'],
          given_name: d['givenName'], surname: d['surname'], phone: d['phone'],
          email: d['email'], address: d['address'], birth_date: d['birthDate'],
          pid: d['pid'], bank_id: d['bankId'],
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
        else raise ArgumentError, "Unknown vipps status: #{d['status']}"
        end
      end
    end

    class Endpoint
      def initialize(transport)
        @transport = transport
      end

      def auth(req)             = Status.from_json(@transport.post('/v3/vipps/auth', req.to_h))
      def backchannel_auth(req) = Status.from_json(@transport.post('/v3/vipps/backchannel/auth', req.to_h))
      def auth_status(id)       = Status.from_json(@transport.get("/v3/vipps/auth/#{id}"))
      def cancel_auth(id)       = @transport.delete("/v3/vipps/auth/#{id}")

      def wait_for_auth(id, opts: PollOptions.new) = poll(opts) { auth_status(id) }

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
    end
  end
end
