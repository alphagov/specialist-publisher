require "spec_helper"

RSpec.describe FinderSchema do
  describe ".schema_names" do
    it "returns schema names" do
      expect(FinderSchema.schema_names).to include("aaib_reports")
    end
  end

  context "the `content_id` keyword arg is passed" do
    let(:content_id) { "853596e7-8ae3-42bd-838b-25ca3076e35f" }
    let(:schema) { FinderSchema.new(content_id:) }

    before do
      payload = JSON.parse(File.read(Rails.root.join("spec/fixtures/publishing_api/get_finder_payload.json")))
      stub_request(:get, "http://publishing-api.dev.gov.uk/v2/content/#{content_id}?locale=en")
        .to_return(status: 200, body: payload.to_json)
    end

    describe "base_path" do
      it "returns the base path" do
        expect(schema.base_path).to eq("/research-for-development-outputs")
      end
    end

    describe "organisations" do
      it "returns the organisations" do
        expect(schema.organisations).to eq([])
      end
    end

    describe "editing_organisations" do
      it "returns the editing_organisations" do
        expect(schema.editing_organisations).to eq([])
      end
    end

    describe "format" do
      it "returns the format" do
        expect(schema.format).to eq("research_for_development_output")
      end
    end

    describe "content_id" do
      it "returns the content_id" do
        expect(schema.content_id).to eq(content_id)
      end
    end

    describe "facets" do
      it "returns the facets names as symbols" do
        expect(schema.facets).to eq(%i[country research_document_type theme first_published_at authors])
      end
    end

    describe "options_for" do
      it "returns options for the given facet name" do
        expect(schema.options_for(:country).first).to eq(%w[Afghanistan AF])
      end
    end

    describe "#humanized_facet_name" do
      it "returns the name defined in the schema for the supplied facet key" do
        expect(schema.humanized_facet_name("research_document_type")).to eq("Document Type")
      end

      it "returns the humanized version of the supplied facet key is not defined in the schema" do
        expect(schema.humanized_facet_name("review_status")).to eq("Review status")
      end
    end

    describe "#humanized_facet_value" do
      context "a text facet" do
        context "with allowed_values " do
          context "looking up a single value" do
            it "returns an array with only the looked-up value" do
              expect(schema.humanized_facet_value("country", "AL")).to eql(%w[Albania])
            end
          end

          context "looking up multiple values" do
            it "returns an array with the looked-up values" do
              expect(schema.humanized_facet_value("country", %w[AL AF])).to eql(%w[Albania Afghanistan])
            end
          end
        end

        context "with an empty set of allowed_values" do
          it "returns the value itself" do
            authors_value = ["Mr. Potato Head", "Mrs. Potato Head"]
            expect(
              schema.humanized_facet_value("authors", authors_value),
            ).to eql(authors_value)
          end
        end
      end

      context "a date facet" do
        it "just returns the value unmodified" do
          expect(schema.humanized_facet_value("first_published_at", "2012-01-01")).to eql("2012-01-01")
        end
      end
    end
  end

  # context "the `schema_type` keyword arg is passed" do
  #   let(:schema) { FinderSchema.new(schema_type: "research_for_development_outputs") }

  #   describe "#humanized_facet_name" do
  #     it "returns the name defined in the schema for the supplied facet key" do
  #       expect(schema.humanized_facet_name("research_document_type")).to eq("Document Type")
  #     end

  #     it "returns the humanized version of the supplied facet key is not defined in the schema" do
  #       expect(schema.humanized_facet_name("review_status")).to eq("Review status")
  #     end
  #   end

  #   describe "#humanized_facet_value" do
  #     context "a text facet" do
  #       context "with allowed_values " do
  #         context "looking up a single value" do
  #           it "returns an array with only the looked-up value" do
  #             expect(schema.humanized_facet_value("country", "AL")).to eql(%w[Albania])
  #           end
  #         end

  #         context "looking up multiple values" do
  #           it "returns an array with the looked-up values" do
  #             expect(schema.humanized_facet_value("country", %w[AL AF])).to eql(%w[Albania Afghanistan])
  #           end
  #         end
  #       end

  #       context "with an empty set of allowed_values" do
  #         it "returns the value itself" do
  #           authors_value = ["Mr. Potato Head", "Mrs. Potato Head"]
  #           expect(
  #             schema.humanized_facet_value("authors", authors_value),
  #           ).to eql(authors_value)
  #         end
  #       end
  #     end

  #     context "a date facet" do
  #       it "just returns the value unmodified" do
  #         expect(schema.humanized_facet_value("first_published_at", "2012-01-01")).to eql("2012-01-01")
  #       end
  #     end
  #   end
  # end
end
