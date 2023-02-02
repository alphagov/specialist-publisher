require "uri"
require "net/http"

module Importers
  module LicenceTransaction
    class FacetTagger
      attr_reader :licence_transaction

      def initialize(licence_transaction)
        @licence_transaction = licence_transaction
      end

      def tag
        licence_transaction.licence_transaction_location = facets&.fetch(:locations)
        licence_transaction.licence_transaction_industry = facets&.fetch(:industry_sectors)
      end

    private

      def facets
        licence_finder_api_data.find do |datum|
          datum[:licence_identifier] == licence_transaction.licence_transaction_licence_identifier
        end
      end

      def licence_finder_api_data
        @licence_finder_api_data ||= licence_finder_api_response.map(&:deep_symbolize_keys)
      end

      def licence_finder_api_response
        Rails.cache.fetch(licence_finder_api_url, expires: 1.hour) do
          response = Net::HTTP.get_response(licence_finder_api_url).body
          JSON.parse(response)
        end
      end

      def licence_finder_api_url
        URI("#{Plek.website_root}/licence-finder/licences-api")
      end
    end
  end
end
