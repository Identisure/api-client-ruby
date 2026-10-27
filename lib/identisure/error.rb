# frozen_string_literal: true

module Identisure
  class IdentisureError < StandardError
    attr_reader :status_code

    def initialize(status_code, message)
      @status_code = status_code
      super("identisure: #{status_code} #{message}")
    end
  end

  class WaitError < StandardError
    attr_reader :timeout

    def initialize(timeout:)
      @timeout = timeout
      super('Poll timed out')
    end
  end
end
