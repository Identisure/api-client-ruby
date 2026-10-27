# frozen_string_literal: true

module Identisure
  module Environment
    PRODUCTION = :production
    STAGING    = :staging

    BASE_URLS = {
      PRODUCTION => 'https://api.identisure.com',
      STAGING    => 'https://stgapi.identisure.com',
    }.freeze

    def self.base_url(env)
      BASE_URLS.fetch(env)
    end
  end
end
