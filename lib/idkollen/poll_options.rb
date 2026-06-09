# frozen_string_literal: true

module Idkollen
  class PollOptions
    attr_reader :interval, :timeout

    def initialize(interval: 2, timeout: 300)
      @interval = interval
      @timeout = timeout
    end
  end
end
