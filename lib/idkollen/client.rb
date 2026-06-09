# frozen_string_literal: true

require 'faraday'
require 'faraday/multipart'
require 'json'

require_relative 'version'
require_relative 'environment'
require_relative 'poll_options'
require_relative 'error'
require_relative 'transport'
require_relative 'age_verification'
require_relative 'bank_id_se'
require_relative 'bank_id_no'
require_relative 'freja'
require_relative 'mit_id'
require_relative 'ftn'
require_relative 'vipps'
require_relative 'document'

module Idkollen
  class Client
    def initialize(transport)
      @transport = transport
    end

    def bank_id_se = BankIdSe::Endpoint.new(@transport)
    def bank_id_no = BankIdNo::Endpoint.new(@transport)
    def freja      = Freja::Endpoint.new(@transport)
    def mit_id     = MitId::Endpoint.new(@transport)
    def ftn        = Ftn::Endpoint.new(@transport)
    def vipps      = Vipps::Endpoint.new(@transport)
    def document   = Document::Endpoint.new(@transport)
  end

  class ClientBuilder
    def initialize(client_id, client_secret)
      @client_id = client_id
      @client_secret = client_secret
      @environment = Environment::PRODUCTION
      @base_url = nil
      @http_client = nil
    end

    def environment(env)
      @environment = env
      self
    end

    def base_url(url)
      @base_url = url
      self
    end

    def http_client(conn)
      @http_client = conn
      self
    end

    def build
      base = @base_url || Environment.base_url(@environment)
      conn = @http_client || build_default_connection(base)
      Client.new(Transport.new(conn))
    end

    private

    def build_default_connection(base)
      Faraday.new(url: base) do |f|
        f.request :authorization, :basic, @client_id, @client_secret
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.request :multipart
        f.headers['User-Agent'] = USER_AGENT
        f.adapter Faraday.default_adapter
      end
    end
  end
end
