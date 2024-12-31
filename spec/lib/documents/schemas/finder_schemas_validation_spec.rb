require "spec_helper"

RSpec.describe "Sense-checks for every finder schema" do
  Dir["lib/documents/schemas/*.json"].map { |file| JSON.parse(File.read(file)) }.each do |finder_schema|
    it "has each of its facets corresponding with a property in Publishing API" do
      # TODO: append "_metadata" to the flood_and_coastal_... finder in Publishing API so that this workaround isn't required
      definition_key = if finder_schema["filter"]["format"] == "flood_and_coastal_erosion_risk_management_research_report"
                         "flood_and_coastal_erosion_risk_management_research_report"
                       else
                         "#{finder_schema['filter']['format']}_metadata"
                       end

      schema = GovukSchemas::Schema.find(
        publisher_schema: "specialist_document",
      )["definitions"][definition_key]

      properties_in_publishing_api = (schema["properties"].keys - %w[bulk_published]).sort
      properties_in_finder_schema = finder_schema["facets"].map { |facet| facet["key"] }.sort

      # TODO: whilst in an ideal world we'd have a direct one-to-one mapping between the
      # properties in the finder schema and the properties in Publishing API
      # (i.e. `expect(properties_in_publishing_api).to eq(properties_in_finder_schema)`)
      # we can't do this yet, as some Finders define properties outside of the schema,
      # e.g. StatutoryInstrument's `withdrawn_date`.
      # So for now, we're just checking that every property defined in the finder
      # schema is actually used in Publishing API.
      expect(properties_in_finder_schema - properties_in_publishing_api).to be_empty, "In the '#{finder_schema['filter']['format']}' finder, the following redundant properties were found: #{(properties_in_finder_schema - properties_in_publishing_api).join(', ')}"
    end

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
        ]
        expect(valid_values).to include(facet["specialist_publisher_properties"]), "In the '#{finder_schema['filter']['format']}' finder, facet '#{facet['key']}' has an invalid 'specialist_publisher_properties' value"
      end
    end
  end
end
