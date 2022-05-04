require "rails_helper"
require "services"
require "importers/protected_food_drink_name/parser"

RSpec.describe Importers::ProtectedFoodDrinkName::Parser do
  describe "#get_attributes" do
    let(:row) do
      {
        "Title" => "Irish Cream",
        "Registered name" => "Irish Cream",
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
        registered_name: "Irish Cream",
        register: "spirit-drinks",
        status: "registered",
        class_category: %w[32-liqueur],
        protection_type: "geographical-indication-gi",
        reason_for_protection: nil,
        country_of_origin: %w[ireland],
        traditional_term_grapevine_product_category: [],
        traditional_term_type: nil,
        traditional_term_language: nil,
        date_application: nil,
        date_registration: "2020-12-31",
        time_registration: "23:00",
        date_registration_eu: nil,
        body: "## Product specification \n\nThe product specification is not yet available on this site. For any enquiries please [email Defra](mailto:protectedfoodnames@defra.gov.uk).\n\n",
        summary: "Protected spirit drink name",
        internal_notes: "The GI covers products from Ireland and Northern Ireland https://www.gov.uk/government/publications/protected-food-name-irish-cream-pgi",
      }

      expect(subject.get_attributes).to eq(expected_result)
    end
  end

  describe "#register" do
    let(:data) do
      [
        { "Product type" => "Wine", "Protection type" => "American viticultural area" },
        { "Product type" => "Wine", "Protection type" => "US spirit drink" },
        { "Product type" => "Wine", "Protection type" => "Name protected by international treaty" },
        { "Product type" => "Aromatised wine" },
        { "Product type" => "Spirit drink" },
        { "Product type" => "Wine" },
        { "Product type" => "Traditional term" },
        { "Product type" => "Food", "Protection type" => "Traditional Specialities Guaranteed (TSG)" },
        { "Product type" => "Food" },
      ]
    end

    it "parses product types and protection types correctly" do
      expected_results = %w[
        american-viticultural-areas
        american-viticultural-areas
        names-protected-by-international-treaty
        aromatised-wines
        spirit-drinks
        wines
        traditional-terms-for-wine
        foods-traditional-speciality-guaranteed
        foods-designated-origin-and-geographical-indication
      ]

      results = data.map { |datum| described_class.new(datum).get_attributes[:register] }

      expect(results).to eq(expected_results)
    end
  end

  describe "#summary" do
    let(:data) do
      [
        {
          "Protection type" => "Geographical indication (GI)",
          "Product type" => "Spirit drink",
        },
        {
          "Protection type" => "Geographical indication (GI)",
          "Product type" => "Aromatised wine",
        },
        {
          "Protection type" => "Protected Geographical Indication (PGI)",
          "Product type" => "Food",
        },
        {
          "Protection type" => "Protected Geographical Indication (PGI)",
          "Product type" => "Wine",
        },
        {
          "Protection type" => "Protected Designation of Origin (PDO)",
          "Product type" => "Food",
        },
        {
          "Protection type" => "Protected Designation of Origin (PDO)",
          "Product type" => "Wine",
        },
        { "Protection type" => "Protected Designation of Origin (PDO)" },
        { "Protection type" => "Traditional Specialities Guaranteed (TSG)" },
        { "Protection type" => "Traditional Term" },
        { "Protection type" => "Name protected by international treaty" },
        { "Protection type" => "American viticultural area" },
        { "Protection type" => "US spirit drink" },
      ]
    end
    it "parses product types and protection types correctly" do
      expected_results = [
        "Protected spirit drink name",
        "Protected aromatised wine name",
        "Protected food name with Protected Geographical Indication (PGI)",
        "Protected wine name with Protected Geographical Indication (PGI)",
        "Protected food name with Protected Designation of Origin (PDO)",
        "Protected wine name with Protected Designation of Origin (PDO)",
        "",
        "Protected food name with Traditional Speciality Guaranteed (TSG)",
        "Traditional term for wine",
        "Name protected by international treaty",
        "American viticultural area",
        "Protected spirit drink name",
      ]

      results = data.map { |datum| described_class.new(datum).get_attributes[:summary] }

      expect(results).to eq(expected_results)
    end
  end
end
