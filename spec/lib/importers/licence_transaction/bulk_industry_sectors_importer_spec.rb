require "spec_helper"
require "importers/licence_transaction/bulk_industry_sectors_importer"

RSpec.describe Importers::LicenceTransaction::BulkIndustrySectorsImporter do
  describe "#imported_json_data" do
    let(:data_file_path) { Rails.root.join("spec/fixtures/licence-transaction/industry_sectors.txt") }
    let(:schema_file_path) { Rails.root.join("spec/fixtures/document/schemas/licence-transactions.json") }

    let(:subject) { described_class.new(data_file_path:, schema_file_path:) }

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
end
