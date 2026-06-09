# frozen_string_literal: true

module Idkollen
  class IdkollenError < StandardError
    attr_reader :status_code

    def initialize(status_code, message)
      @status_code = status_code
      super("idkollen: #{status_code} #{message}")
    end
  end

  class WaitError < StandardError
    attr_reader :timeout, :cause

    def initialize(timeout:, cause: nil)
      @timeout = timeout
      @cause = cause
      super(timeout ? 'Poll timed out' : "Poll error: #{cause}")
    end
  end
end
