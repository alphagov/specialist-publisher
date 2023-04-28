require "spec_helper"
require "importers/licence_transaction/bulk_industry_sectors_importer"

RSpec.describe Importers::LicenceTransaction::BulkIndustrySectorsImporter do
  describe "#call" do
    it "writes imported sectors to JSON schema file" do
      data_file_path = Rails.root.join("spec/fixtures/licence-transaction/industry_sectors.txt")
      schema_file_path = Rails.root.join("spec/fixtures/documents/schemas/licence_transactions.json")
      subject = described_class.new(data_file_path:, schema_file_path:)

      json_blob = File.new(schema_file_path).read
      expected_schema = JSON.pretty_generate(JSON.parse(json_blob))

      expect(File).to receive(:write).with(schema_file_path, expected_schema)
      subject.call
    end
  end
end
