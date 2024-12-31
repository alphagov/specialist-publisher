require "spec_helper"

RSpec.describe "Sense-checks for every finder schema" do
  Dir["lib/documents/schemas/*.json"].map { |file| JSON.parse(File.read(file)) }.each do |finder_schema|
    it "has 'specialist_publisher_properties' for every facet with 'allowed_values'" do
      facets = finder_schema["facets"]

      facets.each do |facet|
        if facet["allowed_values"]
          expect(facet["specialist_publisher_properties"]).to be_truthy, "In the '#{finder_schema['filter']['format']}' finder, facet '#{facet['key']}' is missing 'specialist_publisher_properties' despite having 'allowed_values'"
        end
      end
    end

    it "has 'specialist_publisher_properties' that are valid" do
      finder_schema["facets"].each do |facet|
        next unless facet["specialist_publisher_properties"]

        valid_values = [
          { "select" => "one" },
          { "select" => "multiple" },
          { "omit_from_finder_content_item" => true },
        ]
        expect(valid_values).to include(facet["specialist_publisher_properties"]), "In the '#{finder_schema['filter']['format']}' finder, facet '#{facet['key']}' has an invalid 'specialist_publisher_properties' value"
      end
    end
  end
end
