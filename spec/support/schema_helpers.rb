RSpec.shared_context "schema with humanized_facet_value available" do
  before do
    schema = double
    symbol = "#{document_type}_finder_schema".to_sym
    allow(SpecialistPublisherWiring).to receive(:get).with(symbol).and_return schema
    allow(schema).to receive(:humanized_facet_value).and_return [humanized_facet_value]
  end
end
