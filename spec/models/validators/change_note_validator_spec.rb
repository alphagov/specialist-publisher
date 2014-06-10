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
    )
  }

  let(:change_note) { nil }
  let(:minor_update) { false }

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

          it "is not valid" do
            expect(validatable).not_to be_valid
          end
        end
      end
    end
  end
end
