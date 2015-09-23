require "spec_helper"

RSpec.shared_examples_for "tribunal decision sub_category validator" do

  let(:category_label) { "Category label" }
  let(:humanized_facet_value) { category_label }
  include_context "schema with humanized_facet_value available"

  describe "#errors" do

    context "when sub_category not provided" do
      let(:category) { "category-name" }
      let(:sub_category) { [] }

      context "and parent category has no sub-categories" do
        before do
          allow(finder_schema).to receive(:options_for).with(:tribunal_decision_sub_category).
            and_return [["Other category sub-category", "other-category-sub-category"]]
        end

        it "returns an empty error hash" do
          validatable.valid?
          errors = validatable.errors.messages
          expect(errors).to eq({})
        end
      end

      context "and parent category has sub-categories" do
        before do
          allow(finder_schema).to receive(:options_for).with(:tribunal_decision_sub_category).
            and_return [["Category name sub-category", "category-name-sub-category"]]
        end

        it "returns error for sub_category" do
          validatable.valid?
          errors = validatable.errors.messages
          expect(errors).to eq({
            tribunal_decision_sub_category: ["must not be blank"]
          })
        end
      end
    end

    context "when sub_category has two values" do
      let(:category) { "category-name" }
      let(:sub_category) { %w[category-name-sub-category-1 category-name-sub-category-2] }

      it "returns error for sub_category" do
        validatable.valid?
        errors = validatable.errors.messages
        expect(errors).to eq({
          tribunal_decision_sub_category: ["change to a single sub-category"]
        })
      end
    end

    context "when sub_category does not match category" do
      let(:category) { "category-name" }
      let(:sub_category) { ["non-matching-sub-category"] }

      context "and relevant sub_categories exist" do
        before do
          allow(finder_schema).to receive(:options_for).with(:tribunal_decision_sub_category).
            and_return [["Category name sub-category", "category-name-sub-category"]]
        end

        it "returns change sub-category error message" do
          validatable.valid?
          errors = validatable.errors.messages
          expect(errors).to eq({
            tribunal_decision_sub_category: ["change to be a sub-category of '#{category_label}' or change category"]
          })
        end
      end

      context "and no relevant sub_categories exist" do
        before do
          allow(finder_schema).to receive(:options_for).with(:tribunal_decision_sub_category).
            and_return [["Other category sub-category", "other-category-sub-category"]]
        end

        it "returns remove sub-category error message" do
          validatable.valid?
          errors = validatable.errors.messages
          expect(errors).to eq({
            tribunal_decision_sub_category: ["remove sub-category as '#{category_label}' category has no sub-categories"]
          })
        end
      end
    end

    context "when sub_category matches category" do
      let(:category) { "category-name" }
      let(:sub_category) { ["category-name-subcategory-name"] }

      it "returns an empty error hash" do
        validatable.valid?
        errors = validatable.errors.messages
        expect(errors).to eq({})
      end
    end
  end
end
