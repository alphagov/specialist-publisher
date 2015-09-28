RSpec.shared_examples_for "a tribunal decision indexable formatter" do

  context "with sub_category" do
    let(:sub_category) { [double] }
    it "sends single sub_category for indexing" do
      attributes = formatter.indexable_attributes
      expect(attributes[:tribunal_decision_sub_category]).to eq(sub_category.first)
    end
  end

  context "without sub_category" do
    let(:sub_category) { [] }
    it "sends blank for indexing" do
      attributes = formatter.indexable_attributes
      expect(attributes[:tribunal_decision_sub_category]).to eq(nil)
    end
  end

end
