require "spec_helper"
require "models/valid_against_schema"

RSpec.describe SpecialistDocument::ProtectedFoodDrinkName do
  subject(:payload) { FactoryBot.create(:protected_food_drink_name) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  context "with Greek characters" do
    subject(:document) { ProtectedFoodDrinkName.new(title: "Στερεά Ελλάδα") }

    it "has a valid base_path" do
      expect(document.base_path).to eq("/protected-food-drink-names/sterea-ellada")
    end
  end

  context "with Cyrillic characters" do
    subject(:document) { ProtectedFoodDrinkName.new(title: "Черноморски район") }

    it "has a valid base_path" do
      expect(document.base_path).to eq("/protected-food-drink-names/chiernomorski-raion")
    end
  end
end
