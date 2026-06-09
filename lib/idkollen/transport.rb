# frozen_string_literal: true

require 'faraday'
require 'faraday/multipart'
require 'stringio'

module Idkollen
  USER_AGENT = "idkollen-client-ruby/#{Idkollen::VERSION}"

  class Transport
    def initialize(connection)
      @conn = connection
    end

    def post(path, body)
      handle(@conn.post(path) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = body
      end)
    end

    def get(path)
      handle(@conn.get(path))
    end

    def get_raw(path)
      res = @conn.get(path)
      raise_for(res) unless success?(res)
      res.body.to_s
    end

    def delete(path)
      res = @conn.delete(path)
      raise_for(res) unless success?(res)
      nil
    end

    def post_multipart(path, data, filename, mime_type)
      io = StringIO.new(data)
      part = Faraday::Multipart::FilePart.new(io, mime_type, filename)
      handle(@conn.post(path, file: part))
    end

    private

    def handle(res)
      raise_for(res) unless success?(res)
      body = res.body
      return {} if body.nil? || body == ''
      body.is_a?(Hash) ? body : {}
    end

    def success?(res)
      res.status >= 200 && res.status < 300
    end

    def raise_for(res)
      message =
        case res.body
        when Hash then res.body['message'] || res.body.to_s
        when String then res.body
        else res.body.to_s
        end
      raise IdkollenError.new(res.status, message)
    rescue Faraday::Error => e
      raise IdkollenError.new(0, e.message)
    end
  end
end
