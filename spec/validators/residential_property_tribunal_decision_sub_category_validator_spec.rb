require "spec_helper"

RSpec.describe ResidentialPropertyTribunalDecisionSubCategoryValidator do
  describe "#validate_each" do
    let(:record) { double(:record) }
    let(:errors) { ActiveModel::Errors.new(record) }
    before { allow(record).to receive(:errors).and_return(errors) }

    subject { described_class.new(attributes: [:sub_category]) }

    context "nil values are ignored on the assumption that presence: true validations will be used to detect them so" do
      it "doesn't add an error to the record if the category on the record is blank" do
        allow(record).to receive(:tribunal_decision_category).and_return(nil)
        subject.validate_each(record, :sub_category, "foo---bar")
        expect(record.errors[:sub_category]).to be_empty
      end

      it "doesn't add an error to the record if the sub_category on the record is blank" do
        allow(record).to receive(:tribunal_decision_category).and_return('foo')
        subject.validate_each(record, :sub_category, nil)
        expect(record.errors[:sub_category]).to be_empty
      end
    end

    it "adds an error to the record if the category suffixed by '---' is not a prefix of the sub_category" do
      allow(record).to receive(:tribunal_decision_category).and_return('foo')
      subject.validate_each(record, :sub_category, 'foo-bar')
      expect(record.errors[:sub_category]).to eq(["must belong to the selected tribunal decision category"])
    end

    it "does not add an error to the record if the category suffixed by '---' is a prefix of the sub_category" do
      allow(record).to receive(:tribunal_decision_category).and_return('foo')
      subject.validate_each(record, :sub_category, 'foo---bar')
      expect(record.errors[:sub_category]).to be_empty
    end
  end
end
