# frozen_string_literal: true

module Idkollen
  module Environment
    PRODUCTION = :production
    STAGING    = :staging

    BASE_URLS = {
      PRODUCTION => 'https://api.idkollen.se',
      STAGING    => 'https://stgapi.idkollen.se',
    }.freeze

    def self.base_url(env)
      BASE_URLS.fetch(env)
    end
  end
end
