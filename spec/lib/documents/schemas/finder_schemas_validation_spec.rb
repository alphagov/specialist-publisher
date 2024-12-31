require "spec_helper"

RSpec.describe "Sense-checks for every finder schema" do
  Dir["lib/documents/schemas/*.json"].map { |file| JSON.parse(File.read(file)) }.each do |finder_schema|
    it "has each of its facets corresponding with a property in Publishing API" do
      schema = GovukSchemas::Schema.find(
        publisher_schema: "specialist_document",
      )["definitions"]["#{finder_schema['filter']['format']}_metadata"]

      if !schema
        puts "TODO: the '#{finder_schema['filter']['format']}' finder schema does not have a corresponding hash in the Publishing API. Skipping its validation..."
      else
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
end
