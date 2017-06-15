require 'net/http'

module Liql
  module GraphQL
    class NetworkLayer
      def initialize(uri, headers)
        @uri = URI(uri)
        @headers = headers
      end

      def query(query)
        params = { query: query.to_query_string }
        uri.query = URI.encode_www_form(params)
        request = Net::HTTP::Get.new(uri)

        headers.each do |key, value|
          request[key] = value
        end

        Net::HTTP.start(uri.hostname, uri.port) { |http|
          http.request(request)
        }
      end
    end
  end
end
