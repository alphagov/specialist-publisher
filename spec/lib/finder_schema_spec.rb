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
    expect(finder_schema.options_for(:case_type)).to eq([["CA98 and civil cartels", "ca98-and-civil-cartels"]])
  end
end
