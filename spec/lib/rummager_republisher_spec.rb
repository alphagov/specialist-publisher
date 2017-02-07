require "rails_helper"
require "rummager_republisher"

RSpec.describe RummagerRepublisher do
  describe '.republish_all' do
    it 'delegates content_ids to RummagerBulkRepublisherWorker' do
      # to load all the document types without manually typing them.
      Rails.application.eager_load!
      document_types ||= Document.subclasses.map(&:document_type)

      expect(document_types).to_not be_empty

      url = GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT + "/content"

      content_id = "8afc9def-7363-485f-8afc-8afc7340619b"
      body = {
        "total" => 1,
        "pages" => 1,
        "current_page" => 1,
        "links" => [],
        "results" => [
          {
            "content_id" => content_id,
            "publishing_app" => "specialist-publisher",
            "rendering_app" => "specialist-frontend",
            "document_type" => "aaib_report",
            "base_path" => "/aaib-reports/report-base-path",
          }
        ]
      }

      document_types.each do |document_type|
        params = {
          document_type: document_type,
          fields: [:content_id]
        }

        stub_request(:get, url)
          .with(query: params)
          .to_return(status: 200, body: body.to_json, headers: {})
      end

      allow(
        RummagerBulkRepublisherWorker
      ).to receive(:perform_async).exactly(document_types.size).times

      expect {
        RummagerRepublisher.republish_all
      }.to output(/Schedulling rummager/).to_stdout
    end
  end
end
