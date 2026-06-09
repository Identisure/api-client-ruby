# frozen_string_literal: true

module Idkollen
  module AgeVerification
    class Request
      attr_reader :min_age, :max_age, :ref_id, :callback_url, :redirect_url

      def initialize(min_age: nil, max_age: nil, ref_id: nil, callback_url: nil, redirect_url: nil)
        @min_age = min_age
        @max_age = max_age
        @ref_id = ref_id
        @callback_url = callback_url
        @redirect_url = redirect_url
      end

      def to_h
        {
          minAge: @min_age,
          maxAge: @max_age,
          refId: @ref_id,
          callbackUrl: @callback_url,
          redirectUrl: @redirect_url,
        }.compact
      end
    end

    class Pending
      attr_reader :id, :url, :min_age, :max_age

      def initialize(id:, url: nil, min_age: nil, max_age: nil)
        @id = id; @url = url; @min_age = min_age; @max_age = max_age
      end

      def deconstruct_keys(_) = { id: @id, url: @url, min_age: @min_age, max_age: @max_age }

      def self.from_json(d)
        new(id: d['id'], url: d['url'], min_age: d['minAge'], max_age: d['maxAge'])
      end
    end

    class Completed
      attr_reader :id, :age_verified

      def initialize(id:, age_verified:)
        @id = id; @age_verified = age_verified
      end

      def deconstruct_keys(_) = { id: @id, age_verified: @age_verified }

      def self.from_json(d) = new(id: d['id'], age_verified: d['ageVerified'])
    end

    class Failed
      attr_reader :id, :error

      def initialize(id:, error:)
        @id = id; @error = error
      end

      def deconstruct_keys(_) = { id: @id, error: @error }

      def self.from_json(d) = new(id: d['id'], error: d['error'])
    end

    module Status
      def self.from_json(d)
        case d['status']
        when 'PENDING'   then Pending.from_json(d)
        when 'COMPLETED' then Completed.from_json(d)
        when 'FAILED'    then Failed.from_json(d)
        else raise ArgumentError, "Unknown age verification status: #{d['status']}"
        end
      end
    end
  end
end
