require "rails_helper"
require "importers/protected_food_drink_name/service"

RSpec.describe Importers::ProtectedFoodDrinkName::Service do
  describe ".call" do
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

    context "when there are no errors" do
      it "returns a successful response object" do
        allow_any_instance_of(ProtectedFoodDrinkName).to receive(:save).and_return(true)

        response = described_class.call(row)

        expect(response).to be_successful
      end
    end

    context "when there are errors" do
      it "returns an unsuccessful response object" do
        row["Status"] = nil

        response = described_class.call(row)

        expect(response).to_not be_successful
        expect(response.error).to eq("Registered name: Irish Cream. Status can't be blank")
      end
    end
  end
end
