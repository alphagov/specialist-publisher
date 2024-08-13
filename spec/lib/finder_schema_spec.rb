require "spec_helper"

RSpec.describe FinderSchema do
  let(:mandatory_properties) do
    {
      "base_path" => "stubbed",
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

  describe ".load_schema_for" do
    it "loads the given schema" do
      json = JSON.parse(File.read(Rails.root.join("lib/documents/schemas/aaib_reports.json")))

      expect(FinderSchema.load_schema_for("aaib_reports")).to eq(json)
    end
  end

  describe "#base_path" do
    it "returns the base path" do
      properties = mandatory_properties.merge({ "base_path" => "/research-for-development-outputs" })
      expect(FinderSchema.new(properties).base_path).to eq("/research-for-development-outputs")
    end
  end

  describe "#format" do
    it "returns the format" do
      properties = mandatory_properties.merge({ "filter" => { "format" => "research_for_development_output" } })
      expect(FinderSchema.new(properties).format).to eq("research_for_development_output")
    end
  end

  describe "#content_id" do
    it "returns the content_id" do
      properties = mandatory_properties.merge({ "content_id" => "853596e7-8ae3-42bd-838b-25ca3076e35f" })
      expect(FinderSchema.new(properties).content_id).to eq("853596e7-8ae3-42bd-838b-25ca3076e35f")
    end
  end

  describe "#document_title" do
    it "returns the document title" do
      properties = mandatory_properties.merge({ "document_title" => "foo" })
      expect(FinderSchema.new(properties).document_title).to eq("foo")
    end
  end

  describe "#organisations" do
    it "returns empty array if not present" do
      expect(FinderSchema.new(mandatory_properties).organisations).to eq([])
    end

    it "returns the organisations if present" do
      properties = mandatory_properties.merge({ "organisations" => %w[f9fcf3fe-2751-4dca-97ca-becaeceb4b26] })
      expect(FinderSchema.new(properties).organisations).to eq(%w[f9fcf3fe-2751-4dca-97ca-becaeceb4b26])
    end
  end

  describe "#editing_organisations" do
    it "returns empty array if not present" do
      expect(FinderSchema.new(mandatory_properties).editing_organisations).to eq([])
    end

    it "returns the editing_organisations if present" do
      properties = mandatory_properties.merge({ "editing_organisations" => %w[def456] })
      expect(FinderSchema.new(properties).editing_organisations).to eq(%w[def456])
    end
  end

  describe "#taxons" do
    it "returns empty array if not present" do
      expect(FinderSchema.new(mandatory_properties).taxons).to eq([])
    end

    it "returns the taxons if present" do
      properties = mandatory_properties.merge({ "taxons" => %w[951ece54-c6df-4fbc-aa18-1bc629815fe2] })
      expect(FinderSchema.new(properties).taxons).to eq(%w[951ece54-c6df-4fbc-aa18-1bc629815fe2])
    end
  end

  describe "#facets" do
    it "returns the facet keys" do
      properties = mandatory_properties.merge({
        "facets" => [
          {
            "key" => "research_document_type",
            "name" => "Document Type",
          },
          {
            "key" => "something_else",
            "name" => "Foo",
          },
        ],
      })
      expect(FinderSchema.new(properties).facets).to eq(%i[research_document_type something_else])
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
  end
end
