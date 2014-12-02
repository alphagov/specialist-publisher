require "formatters/abstract_specialist_document_indexable_formatter"

RSpec.shared_examples_for "a specialist document indexable formatter" do
  describe "last update" do
    it "returns the document's last_published_at if it is a minor update" do
      last_published_at = double(:last_published_at)
      expect(document).to receive(:last_published_at).and_return(last_published_at)
      allow(document).to receive(:minor_update?).and_return(true)

      expect(formatter.indexable_attributes[:last_update]).to eq(last_published_at)
    end

    it "returns the document's updated_at if it is a major update" do
      updated_at = double(:updated_at)
      expect(document).to receive(:updated_at).and_return(updated_at)

      expect(formatter.indexable_attributes[:last_update]).to eq(updated_at)
    end
  end
end
