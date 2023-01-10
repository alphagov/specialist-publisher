require "spec_helper"
require "importers/licence_transaction/bulk_industry_sectors_importer"

RSpec.describe Importers::LicenceTransaction::BulkIndustrySectorsImporter do
  describe "#call" do
    let(:subject) { described_class.new }

    before do
      @sectors_data_file = File.open(subject.file_path, "r")
    end

    it "returns all of the level 2 sectors" do
      sectors = JSON.parse(subject.call)

      expect(sectors.size).to eq(@sectors_data_file.readlines.size)
    end

    it "returns a label and value for each sector" do
      sectors = JSON.parse(subject.call)

      expect(sectors.first).to have_key("label")
      expect(sectors.first).to have_key("value")
    end
  end
end
