require "fast_spec_helper"

require "validators/change_note_validator"

RSpec.describe ChangeNoteValidator do
  subject(:validatable) {
    ChangeNoteValidator.new(entity)
  }

  let(:entity) {
    double(
      :entity,
      change_note: change_note,
      minor_update?: minor_update,
      published?: published,
      errors: entity_errors,
      valid?: entity_valid,
    )
  }

  let(:change_note) { nil }
  let(:minor_update) { false }
  let(:published) { false }
  let(:entity_errors) {
    double(
      :entity_errors_uncast,
      to_hash: entity_errors_hash,
    )
  }
  let(:entity_errors_hash) { {} }
  let(:entity_valid) { false }

  describe "#valid?" do
    context "when the underlying entity is not valid" do
      before do
        allow(entity).to receive(:valid?).and_return(false)
      end

      it "is not valid" do
        expect(validatable).not_to be_valid
      end
    end

    context "when the entity is otherwise valid" do
      before do
        allow(entity).to receive(:valid?).and_return(true)
      end

      context "when the entity has never been published" do
        let(:published) { false }

        it "is valid without a change note" do
          expect(validatable).to be_valid
        end
      end

      context "when the entity has been published" do
        let(:published) { true }
        context "when the entity has a change note" do
          let(:change_note) { "Awesome update!" }

          it "is valid" do
            expect(validatable).to be_valid
          end
        end

        context "when the entity does not have a change note" do
          context "when the update is minor" do
            let(:minor_update) { true }

            it "is valid" do
              expect(validatable).to be_valid
            end
          end

          context "when the update is not minor" do
            let(:minor_update) { false }

            it "calls #valid? on the entity" do
              validatable.valid?

              expect(entity).to have_received(:valid?)
            end

            it "is not valid" do
              expect(validatable).not_to be_valid
            end
          end
        end
      end
    end
  end

  describe "#errors" do
    context "when a change note is missing" do
      let(:change_note) { nil }
      let(:minor_update) { false }
      let(:published) { true }

      before do
        validatable.valid?
      end

      it "returns an error string for that field" do
        expect(validatable.errors.fetch(:change_note))
          .to eq(["You must provide a change note or indicate minor update"])
      end

      context "when the underlying entity has errors" do
        let(:entity_errors_hash) {
          {
            another_field: ["is not valid"],
          }
        }

        it "combines all errors" do
          expect(validatable.errors.fetch(:another_field))
            .to eq(["is not valid"])
        end
      end
    end

    context "transitioning from invalid to valid" do
      let(:change_note) { nil }
      let(:minor_update) { false }
      let(:published) { true }
      let(:entity_valid) { true }

      before do
        validatable.valid?
        allow(entity).to receive(:change_note).and_return("Updated")
        validatable.valid?
      end

      it "resets the errors, returning an empty hash" do
        expect(validatable.errors).to eq({})
      end
    end
  end
end
