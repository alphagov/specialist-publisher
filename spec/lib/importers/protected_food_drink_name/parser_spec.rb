require "rails_helper"
require "services"
require "importers/protected_food_drink_name/parser"

RSpec.describe Importers::ProtectedFoodDrinkName::Parser do
  describe "#get_attributes" do
    let(:row) do
      {
        "Registered product name" => "Irish Cream",
        "Status" => "Registered",
        "Class or category of product" => "32. Liqueur",
        "Protection type" => "Geographical indication (GI)",
        "Country of origin" => "Ireland",
        "Traditional term grapevine product category" => nil,
        "Traditional term type" => nil,
        "Traditional term language" => nil,
        "Date of application" => nil,
        "Date of UK registration" => "31/12/2020",
        "Date of original registration with the EU" => nil,
        "Decision notice" => nil,
        "Protection instrument" => nil,
        "Date of publication of the instrument" => nil,
        "Legislation" => nil,
        "Summary" => nil,
        "Product type" => "Spirit drink",
        "Internal notes" => "The GI covers products from Ireland and Northern Ireland https://www.gov.uk/government/publications/protected-food-name-irish-cream-pgi",
      }
    end

    subject { described_class.new(row) }

    it "parses the content of a Csv::Row into attributes that match ProtectedFoodDrinkName formats" do
      expected_result = {
        title: "Irish Cream",
        register: "spirit-drinks",
        status: "registered",
        class_category: %w[32-liqueur],
        protection_type: "geographical-indication-gi",
        country_of_origin: %w[ireland],
        traditional_term_grapevine_product_category: [],
        traditional_term_type: nil,
        traditional_term_language: nil,
        date_application: nil,
        date_registration: "2020-12-31",
        date_registration_eu: nil,
        body: "## Product specification \n\nThe product specification is not available on this site. Find out how to [get a product specification for a protected food name](https://www.gov.uk/link-to-follow) on GOV.UK.\n\n",
        summary: "Protected spirit drink name",
        internal_notes: "The GI covers products from Ireland and Northern Ireland https://www.gov.uk/government/publications/protected-food-name-irish-cream-pgi",
      }

      expect(subject.get_attributes).to eq(expected_result)
    end
  end
end
