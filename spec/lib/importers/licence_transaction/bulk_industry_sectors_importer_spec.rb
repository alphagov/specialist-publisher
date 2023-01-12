require "spec_helper"
require "importers/licence_transaction/bulk_industry_sectors_importer"

RSpec.describe Importers::LicenceTransaction::BulkIndustrySectorsImporter do
  let(:data_file_path) { Rails.root.join("spec/fixtures/licence-transaction/industry_sectors.txt") }
  let(:schema_file_path) { Rails.root.join("spec/fixtures/documents/schemas/licence_transactions.json") }

  let(:subject) { described_class.new(data_file_path:, schema_file_path:) }

  describe "#imported_json_data" do
    it "returns all of the level 2 sectors" do
      sectors = subject.imported_json_data
      sectors_data_file = File.open(subject.data_file_path, "r")

      expect(sectors.size).to eq(sectors_data_file.readlines.size)
    end

    it "returns a label and value for each sector" do
      sectors = subject.imported_json_data

      expect(sectors.first).to have_key("label")
      expect(sectors.first).to have_key("value")
    end
  end

  describe "#update_industry_sectors_in_schema" do
    it "writes imported sectors to JSON file" do
      json_blob = File.new(schema_file_path).read
      expected_schema = JSON.dump(JSON.parse(json_blob))
      sectors = subject.imported_json_data

      expect(File).to receive(:write).with(schema_file_path, expected_schema)
      subject.update_industry_sectors_in_schema(sectors)
    end
  end
end
