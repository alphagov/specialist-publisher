require "spec_helper"

describe FinderSchema do
  let(:schema_file) {
    File.dirname(__FILE__) + "/../fixtures/sample_schema.json"
  }

  let(:finder_schema) {
    FinderSchema.new(schema_file)
  }

  it "gives a list of facets" do
    expect(finder_schema.facets).to eq([:case_type])
  end

  it "gives the options for a given facet" do
    expect(finder_schema.options_for(:case_type)).to eq([
      ["CA98 and civil cartels", "ca98-and-civil-cartels"],
      ["Criminal cartels", "criminal-cartels"]
    ])
  end

  describe "#humanized_facet_value" do
    context "with facet_key in schema" do
      context "and value in allowed_values config" do
        it "should return label" do
          label = finder_schema.humanized_facet_value(:case_type, "ca98-and-civil-cartels")
          expect(label).to eq(["CA98 and civil cartels"])
        end
      end

      context "and values in allowed_values config" do
        it "should return labels" do
          labels = finder_schema.humanized_facet_value(:case_type, %w[ca98-and-civil-cartels criminal-cartels])
          expect(labels).to eq(["CA98 and civil cartels", "Criminal cartels"])
        end
      end

      context "and value not in allowed_values config" do
        it "should raise exception" do
          expect { finder_schema.humanized_facet_value(:case_type, "bad-value") }.to raise_exception
        end
      end
    end

    context "with facet_key not in schema" do
      it "should raise exception" do
        expect { finder_schema.humanized_facet_value(:bad_key, "ca98-and-civil-cartels") }.to raise_exception
      end
    end
  end
end
