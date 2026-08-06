# frozen_string_literal: true

require 'faraday'
require 'json'
require 'securerandom'

module Idkollen
  USER_AGENT = "idkollen-client-ruby/#{Idkollen::VERSION}"

  class Transport
    def initialize(connection, base_url, client_id, client_secret)
      @conn = connection
      @base_url = base_url.chomp('/')
      @authorization = "Basic #{["#{client_id}:#{client_secret}"].pack('m0')}"
    end

    def inspect = "#<#{self.class.name}>"

    def post(path, body)
      parse(send_request(:post, path, JSON.generate(body), 'Content-Type' => 'application/json'))
    end

    def get(path)
      parse(send_request(:get, path))
    end

    def get_raw(path)
      send_request(:get, path).body.to_s
    end

    def delete(path)
      send_request(:delete, path)
      nil
    end

    def post_multipart(path, data, filename, mime_type)
      boundary = "idkollen-#{SecureRandom.hex(16)}"
      escaped = filename.gsub('"', '%22').gsub("\r", '%0D').gsub("\n", '%0A')
      body = String.new(encoding: Encoding::BINARY)
      body << "--#{boundary}\r\n".b
      body << %(Content-Disposition: form-data; name="file"; filename="#{escaped}"\r\n).b
      body << "Content-Type: #{mime_type}\r\n\r\n".b
      body << data.b
      body << "\r\n--#{boundary}--\r\n".b
      parse(send_request(:post, path, body, 'Content-Type' => "multipart/form-data; boundary=#{boundary}"))
    end

    private

    def send_request(method, path, body = nil, headers = {})
      headers = headers.merge('Authorization' => @authorization, 'User-Agent' => USER_AGENT)
      res = @conn.run_request(method, @base_url + path, body, headers)
      raise IdkollenError.new(res.status, error_message(res.body)) unless res.success?
      res
    rescue Faraday::Error => e
      raise IdkollenError.new(0, e.message)
    end

    def parse(res)
      body = res.body
      return body if body.is_a?(Hash)

      parsed = JSON.parse(body.to_s)
      raise IdkollenError.new(res.status, 'Response body is not a JSON object') unless parsed.is_a?(Hash)

      parsed
    rescue JSON::ParserError => e
      raise IdkollenError.new(res.status, "Invalid JSON response: #{e.message}")
    end

    def error_message(body)
      return body['message'] || body.to_s if body.is_a?(Hash)

      parsed = JSON.parse(body.to_s)
      parsed.is_a?(Hash) && parsed['message'] ? parsed['message'] : body.to_s
    rescue JSON::ParserError
      body.to_s
    end
  end
end
