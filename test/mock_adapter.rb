# frozen_string_literal: true

require 'faraday'
require 'json'

# MockAdapter wraps Faraday::Adapter::Test so tests can enqueue responses by HTTP method,
# regardless of path. Captures requests for assertion.
class MockAdapter
  attr_reader :requests

  def initialize
    @queue = []
    @requests = []
  end

  def enqueue(status, body)
    if body.is_a?(String)
      body_str = body
      # Use octet-stream for non-JSON strings (e.g. raw binary file downloads)
      content_type = if body_str.empty?
        'application/json'
      else
        begin
          JSON.parse(body_str)
          'application/json'
        rescue JSON::ParserError
          'application/octet-stream'
        end
      end
    else
      body_str = JSON.dump(body)
      content_type = 'application/json'
    end
    @queue << [status, body_str, content_type]
  end

  def last_request = @requests.last
  def last_request_body = last_request[:body]

  def connection
    queue = @queue
    requests = @requests
    Faraday.new do |f|
      f.adapter :test do |stubs|
        catch_all = proc do |env|
          requests << {
            method: env.method,
            url: env.url,
            path: env.url.path,
            headers: env.request_headers.dup,
            body: env.body.dup,
            timeout: env.request.timeout,
          }
          raise 'No mock responses queued' if queue.empty?

          status, body, content_type = queue.shift
          [status, { 'content-type' => content_type }, body]
        end
        %i[get post delete put patch].each do |m|
          stubs.send(m, /.*/, &catch_all)
        end
      end
    end
  end
end
