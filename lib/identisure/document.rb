# frozen_string_literal: true

module Identisure
  module Document
    class UploadResponse
      attr_reader :id, :document_hash

      def initialize(id:, document_hash:)
        @id = id; @document_hash = document_hash
      end

      def deconstruct_keys(_) = { id: @id, document_hash: @document_hash }
      def self.from_json(d) = new(id: d['id'], document_hash: d['hash'])
    end

    class Endpoint
      def initialize(transport)
        @transport = transport
      end

      def upload(data, filename, mime_type: 'application/pdf')
        UploadResponse.from_json(@transport.post_multipart('/v3/document', data, filename, mime_type))
      end

      def download(id)
        @transport.get_raw("/v3/document/#{id}")
      end
    end
  end
end
