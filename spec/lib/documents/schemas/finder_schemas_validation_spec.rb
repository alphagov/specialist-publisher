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
      # e.g. 'hidden_indexable_content'.
      # So for now, we're just checking that every property defined in the finder
      # schema is actually used in Publishing API.
      expect(properties_in_finder_schema - properties_in_publishing_api).to be_empty, "In the '#{finder_schema['filter']['format']}' finder, the following redundant properties were found: #{(properties_in_finder_schema - properties_in_publishing_api).join(', ')}"
    end
  end
end
