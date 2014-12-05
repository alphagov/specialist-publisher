require "formatters/abstract_specialist_document_indexable_formatter"

RSpec.shared_examples_for "a specialist document indexable formatter" do
  describe "last update" do
    it "returns the document's updated_at" do
      updated_at = double(:updated_at)
      expect(document).to receive(:updated_at).and_return(updated_at)

      expect(formatter.indexable_attributes[:last_update]).to eq(updated_at)
    end
  end
end
