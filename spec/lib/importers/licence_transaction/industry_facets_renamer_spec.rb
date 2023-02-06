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
end
