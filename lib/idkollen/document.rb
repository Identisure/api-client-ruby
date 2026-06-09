# frozen_string_literal: true

module Idkollen
  module Document
    class UploadResponse
      attr_reader :id, :hash
      def initialize(id:, hash:)
        @id = id; @hash = hash
      end
      def deconstruct_keys(_) = { id: @id, hash: @hash }
      def self.from_json(d) = new(id: d['id'], hash: d['hash'])
    end

    class Endpoint
      def initialize(transport)
        @transport = transport
      end

      def upload(data, filename, mime_type: 'application/pdf')
        UploadResponse.from_json(@transport.post_multipart('/document', data, filename, mime_type))
      end

      def download(id)
        @transport.get_raw("/document/#{id}")
      end

      def delete(id)
        @transport.delete("/document/#{id}")
      end
    end
  end
end
