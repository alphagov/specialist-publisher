require "spec_helper"
require "importers/licence_transaction/industry_facets_renamer"

RSpec.describe Importers::LicenceTransaction::IndustryFacetsRenamer do
  describe "#call" do
    it "reads new sector names into hash" do
      industry_names = described_class.new.call
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

      expect(industry_names.first).to eq(expected_hash)
    end
  end
end
