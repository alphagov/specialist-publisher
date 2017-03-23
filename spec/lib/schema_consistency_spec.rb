require 'spec_helper'
require 'govuk_schemas'
require "finder_schema_converter"

RSpec.describe "the finder schemas" do
  def specialist_document_schema_definitions
    GovukSchemas::Schema.find(publisher_schema: "specialist_document")["definitions"]
  end

  context "all facets on finder schema should appear as metadata in the specialist document schema" do
    FinderSchemaConverter.except_ignored_finders.each do |finder_schema|
      document_type = finder_schema.document_type

      it "should include the metadata fields for #{document_type}" do
        expect(
          specialist_document_schema_definitions["#{document_type}_metadata"]["properties"]

        ).to include(finder_schema.definition["#{document_type}_metadata"]["properties"])
      end
    end
  end
end
