require "spec_helper"

RSpec.describe FinderSchema do
  let(:mandatory_properties) do
    {
      "base_path" => "stubbed",
      "target_stack" => "live",
      "content_id" => "stubbed",
      "document_title" => "stubbed",
      "filter" => {
        "format" => "stubbed",
      },
    }
  end

  describe ".schema_names" do
    it "returns schema names" do
      expect(FinderSchema.schema_names).to include("aaib_reports")
    end
  end

  describe ".load_from_schema" do
    it "loads the given schema" do
      expect(FinderSchema.load_from_schema("aaib_reports")).to be_a(FinderSchema)
    end
  end

  describe "#as_json" do
    it "excludes nil values" do
      schema = FinderSchema.new(mandatory_properties)
      schema.signup_link = nil
      expect(schema.as_json.key?(:signup_link)).to be_falsey
    end

    it "excludes blank values" do
      schema = FinderSchema.new(mandatory_properties)
      schema.summary = ""
      expect(schema.as_json.key?(:summary)).to be_falsey
    end
  end

  describe "#format" do
    it "returns the format" do
      properties = mandatory_properties.merge({ "filter" => { "format" => "research_for_development_output" } })
      expect(FinderSchema.new(properties).format).to eq("research_for_development_output")
    end
  end

  describe "#remove_empty_organisations" do
    it "removes empty organisations on update" do
      schema = FinderSchema.new
      schema.organisations = %w[abc123 def456]
      schema.update(organisations: ["", "def456"])
      expect(schema.organisations).to eq(%w[def456])
    end
  end

  describe "#remove_empty_related_links" do
    it "removes empty related link items on update" do
      schema = FinderSchema.new
      schema.related = %w[abc123 def456]
      schema.update(related: ["", "def456"])
      expect(schema.related).to eq(%w[def456])
    end
  end

  describe "#humanized_facet_name" do
    it "returns the name defined in the schema for the supplied facet key" do
      properties = mandatory_properties.merge({
        "facets" => [
          {
            "key" => "research_document_type",
            "name" => "Document Type",
          },
        ],
      })
      expect(FinderSchema.new(properties).humanized_facet_name("research_document_type")).to eq("Document Type")
    end

    it "returns the humanized version of the supplied facet key is not defined in the schema" do
      expect(FinderSchema.new(mandatory_properties).humanized_facet_name("review_status")).to eq("Review status")
    end

    context "the key is a nested facet" do
      it "returns the name defined in the schema for the supplied facet key" do
        properties = mandatory_properties.merge(
          {
            "facets" => [
              {
                "key" => "parent_facet_key",
                "name" => "Parent facet name",
                "sub_facet_key" => "sub_facet_key",
                "sub_facet_name" => "Sub Facet Name",
                "allowed_values" => [
                  {
                    "label" => "Facet label",
                    "value" => "parent-facet-value",
                    "sub_facets" => [
                      {
                        "label" => "Sub Facet label 1",
                        "value" => "sub-facet-value-1",
                      },
                    ],
                  },
                ],
              },
            ],
          },
        )

        expect(FinderSchema.new(properties).humanized_facet_name("sub_facet_key")).to eq("Sub Facet Name")
      end

      it "returns the humanized version of the supplied nested facet key if not defined in the schema" do
        expect(FinderSchema.new(mandatory_properties).humanized_facet_name("no_key_in_schema")).to eq("No key in schema")
      end
    end
  end

  describe "#humanized_facet_value" do
    context "a text facet" do
      context "with allowed_values " do
        let(:properties) do
          mandatory_properties.merge({
            "facets" => [
              "key" => "country",
              "type" => "text",
              "allowed_values" => [
                {
                  "value" => "AF",
                  "label" => "Afghanistan",
                },
                {
                  "value" => "AL",
                  "label" => "Albania",
                },
              ],
            ],
          })
        end

        context "looking up a single value" do
          it "returns an array with only the looked-up value" do
            expect(FinderSchema.new(properties).humanized_facet_value("country", "AL")).to eql(%w[Albania])
          end
        end

        context "looking up multiple values" do
          it "returns an array with the looked-up values" do
            expect(FinderSchema.new(properties).humanized_facet_value("country", %w[AL AF])).to eql(%w[Albania Afghanistan])
          end

          it "omits values that are not allowed in the schema" do
            expect(FinderSchema.new(properties).humanized_facet_value("country", %w[NA AF])).to eql(%w[Afghanistan])
          end
        end
      end

      context "with an empty set of allowed_values" do
        it "returns the value itself" do
          authors_value = ["Mr. Potato Head", "Mrs. Potato Head"]
          expect(
            FinderSchema.new(mandatory_properties).humanized_facet_value("authors", authors_value),
          ).to eql(authors_value)
        end
      end
    end

    context "a date facet" do
      it "just returns the value unmodified" do
        expect(
          FinderSchema.new(mandatory_properties).humanized_facet_value("first_published_at", "2012-01-01"),
        ).to eql("2012-01-01")
      end
    end

    context "the key is a nested facet" do
      it "appends the parent label to the facet label defined in the schema for the supplied value" do
        properties = mandatory_properties.merge(
          {
            "facets" => [
              {
                "key" => "parent_facet_key",
                "type" => "nested",
                "name" => "Parent facet name",
                "sub_facet_key" => "sub_facet_key",
                "sub_facet_name" => "Sub Facet Name",
                "allowed_values" => [
                  {
                    "label" => "Facet label",
                    "value" => "parent-facet-value",
                    "sub_facets" => [
                      {
                        "label" => "Sub Facet label 1",
                        "value" => "sub-facet-value-1",
                      },
                      {
                        "label" => "Sub Facet label 2",
                        "value" => "sub-facet-value-2",
                      },
                    ],
                  },
                ],
              },
            ],
          },
        )

        expect(FinderSchema.new(properties).humanized_facet_value("sub_facet_key", "sub-facet-value-1")).to eq(["Facet label - Sub Facet label 1"])
        expect(FinderSchema.new(properties).humanized_facet_value("sub_facet_key", "sub-facet-value-2")).to eq(["Facet label - Sub Facet label 2"])
      end

      it "returns received value if subfacets are not defined" do
        properties = mandatory_properties.merge(
          {
            "facets" => [
              {
                "key" => "parent_facet_key",
                "name" => "Parent facet name",
                "sub_facet_key" => "sub_facet_key",
                "sub_facet_name" => "Sub Facet Name",
                "allowed_values" => [
                  {
                    "label" => "Facet label",
                    "value" => "parent-facet-value",
                  },
                ],
              },
            ],
          },
        )

        expect(FinderSchema.new(properties).humanized_facet_value("sub_facet_key", "sub-facet-value-1")).to eq("sub-facet-value-1")
      end
    end
  end

  describe "#allowed_values_for" do
    context "the key is a nested facet" do
      it "returns array of all nested label and values for all parent facet options" do
        properties = mandatory_properties.merge(
          {
            "facets" => [
              {
                "key" => "parent_facet_key",
                "name" => "Parent facet name",
                "sub_facet_key" => "sub_facet_key",
                "sub_facet_name" => "Sub Facet Name",
                "allowed_values" => [
                  {
                    "label" => "Facet label",
                    "value" => "parent-facet-value",
                    "sub_facets" => [
                      {
                        "label" => "Sub Facet label 1",
                        "value" => "sub-facet-value-1",
                      },
                      {
                        "label" => "Sub Facet label 2",
                        "value" => "sub-facet-value-2",
                      },
                    ],
                  },
                ],
              },
            ],
          },
        )

        expected = [
          {
            "label" => "Facet label - Sub Facet label 1",
            "value" => "sub-facet-value-1",
          },
          {
            "label" => "Facet label - Sub Facet label 2",
            "value" => "sub-facet-value-2",
          },
        ]

        expect(FinderSchema.new(properties).allowed_values_for("sub_facet_key")).to eq(expected)
      end

      it "returns empty array if no nested facet values are defined" do
        properties = mandatory_properties.merge(
          {
            "facets" => [
              {
                "key" => "parent_facet_key",
                "name" => "Parent facet name",
                "sub_facet_key" => "sub_facet_key",
                "sub_facet_name" => "Sub Facet Name",
                "allowed_values" => [
                  {
                    "label" => "Facet label",
                    "value" => "parent-facet-value",
                  },
                ],
              },
            ],
          },
        )

        expect(FinderSchema.new(properties).allowed_values_for("sub_facet_key")).to eq([])
      end
    end
  end
end
