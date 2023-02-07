require "spec_helper"
require "importers/licence_transaction/industry_facets_renamer"

RSpec.describe Importers::LicenceTransaction::IndustryFacetsRenamer do
  describe "#call" do
    it "reads new sector names into hash" do
      data_file_path = Rails.root.join("spec/fixtures/licence-transaction/renamed_industries.csv")
      industry_names = described_class.new(csv_file_path: data_file_path).call

      expected_hash = {
        original: {
          label: "Accommodation",
          value: "accommodation",
        },
        new: {
          label: "Accommodation including hotels, holiday homes and campsites",
          value: "accommodation-including-hotels-holiday-homes-and-campsites",
        },
      }

      expect(industry_names.first).to include(expected_hash)
    end
  end

  describe "#changing_industry_values" do
    it "returns list of changing industries" do
      data_file_path = Rails.root.join("spec/fixtures/licence-transaction/renamed_industries.csv")
      changing_industries = described_class.new(csv_file_path: data_file_path).changing_industry_values

      expect(changing_industries.size).to eq(8)
      expect(changing_industries).to include("advertising-and-marketing-services")
      expect(changing_industries).to_not include("arts-and-entertainment")
    end
  end

  describe "#update_schema" do
    it "writes imported sectors to JSON schema file" do
      csv_file_path = Rails.root.join("spec/fixtures/licence-transaction/renamed_industries.csv")
      schema_file_path = Rails.root.join("spec/fixtures/documents/schemas/licence_transactions_with_renamed_industries.json")
      subject = described_class.new(csv_file_path:, schema_file_path:)

      json_blob = File.new(schema_file_path).read
      expected_schema = JSON.dump(JSON.parse(json_blob))

      expect(File).to receive(:write).with(schema_file_path, expected_schema)
      subject.update_schema
    end
  end

  describe "#update_licence_transactions" do
    it "updates licences with the new industry values" do
      csv_file_path = Rails.root.join("spec/fixtures/licence-transaction/renamed_industries.csv")
      schema_file_path = Rails.root.join("spec/fixtures/documents/schemas/licence_transactions_with_renamed_industries.json")

      FactoryBot.build(
        :licence_transaction_model,
        base_path: "/find-licences/1",
        title: "Licence #1",
        licence_transaction_industry: %w[
          accommodation
          arts-and-entertainment
        ],
      )

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

      stub_publishing_api_has_content(
        [document],
        hash_including(document_type: "licence_transaction", page: "1"),
      )
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

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
      )
    end
  end
end
