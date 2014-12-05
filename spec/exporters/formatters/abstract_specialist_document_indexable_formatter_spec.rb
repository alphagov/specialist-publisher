require "formatters/abstract_specialist_document_indexable_formatter"

RSpec.shared_examples_for "a specialist document indexable formatter" do
  describe "last update" do
    it "returns the document's major_updated_at" do
      major_updated_at = double(:previous_major_updated_at)
      expect(document).to receive(:previous_major_updated_at).and_return(major_updated_at)

      expect(formatter.indexable_attributes[:last_update]).to eq(major_updated_at)
    end
  end
end
