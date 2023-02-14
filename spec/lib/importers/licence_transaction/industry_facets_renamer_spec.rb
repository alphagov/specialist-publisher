require "spec_helper"
require "importers/licence_transaction/industry_facets_renamer"

RSpec.describe Importers::LicenceTransaction::IndustryFacetsRenamer do
  let(:csv_file_path) { Rails.root.join("spec/fixtures/licence-transaction/renamed_industries.csv") }
  let(:schema_file_path) { Rails.root.join("spec/fixtures/documents/schemas/licence_transactions_with_renamed_industries.json") }

  describe "#update_schema" do
    it "writes imported sectors to JSON schema file" do
      json_blob = File.new(schema_file_path).read
      expected_schema = JSON.dump(JSON.parse(json_blob))

      expect(File).to receive(:write).with(schema_file_path, expected_schema)
      described_class.new(csv_file_path:, schema_file_path:).update_schema
    end
  end

  describe "#update_licence_transactions" do
    it "updates licences with the new industry values" do
      document = FactoryBot.create(
        :licence_transaction,
        base_path: "/find-licences/1",
        title: "Licence #1",
        default_metadata: {
          "licence_transaction_industry" => %w[
            accommodation
            arts-and-entertainment
          ],
        },
      )

      FactoryBot.build(
        :licence_transaction_model,
        base_path: "/find-licences/1",
        title: "Licence #1",
        licence_transaction_industry: %w[
          accommodation
          arts-and-entertainment
        ],
      )

      stub_publishing_api_has_content(
        [document],
        hash_including(document_type: "licence_transaction", page: "1"),
      )
      stub_publishing_api_has_item(document)

      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      stub_any_publishing_api_publish
      stub_any_email_alert_api_call

      described_class.new(csv_file_path:, schema_file_path:).update_licence_transactions

      expected_details_hash = {
        details: {
          body: [
            {
              content_type: "text/govspeak",
              content: "default text",
            },
          ],
          metadata: {
            licence_transaction_industry: %w[
              arts-and-entertainment
              accommodation-including-hotels-holiday-homes-and-campsites
            ],
          },
          max_cache_time: 10,
          temporary_update_type: false,
        },
      }

      assert_publishing_api_put_content(
        document["content_id"],
        request_json_includes(expected_details_hash),
        2,
      )
      assert_publishing_api_publish(document["content_id"])
    end
  end
end
