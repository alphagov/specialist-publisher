RSpec.shared_context "schema with humanized_facet_value available" do
  let(:finder_schema) { double }

  before do
    symbol = "#{document_type}_finder_schema".to_sym
    allow(SpecialistPublisherWiring).to receive(:get).with(symbol).and_return finder_schema
    allow(finder_schema).to receive(:humanized_facet_value).and_return [humanized_facet_value]
  end
end
