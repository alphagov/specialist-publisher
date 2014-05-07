require "fast_spec_helper"

require "validators/slug_uniqueness_validator"

describe SlugUniquenessValidator do
  subject(:document_with_validator) {
    SlugUniquenessValidator.new(document_repository, document)
  }

  let(:document) { double(:document, slug: slug, valid?: true, errors: {}) }
  let(:document_repository) { double(:document_repository, slug_unique?: true) }
  let(:slug) { double(:slug) }

  it "is a true decorator" do
    expect(document).to receive(:arbitrary_message)

    document_with_validator.arbitrary_message
  end

  describe "#valid?" do
    it "searches the repository for a document with the same slug" do
      document_with_validator.valid?

      expect(document_repository).to have_received(:slug_unique?).with(document)
    end

    it "validates the underlying document" do
      document_with_validator.valid?

      expect(document).to have_received(:valid?)
    end

    context "when the no other document has the same slug" do
      before do
        allow(document_repository).to receive(:slug_unique?)
          .and_return(true)
      end

      it "returns true" do
        expect(document_with_validator).to be_valid
      end

      it "reports no errors" do
        document_with_validator.valid?

        expect(document_with_validator.errors).to be_empty
      end

      context "when the document has other errors" do
        let(:existing_errors) { { field_name: ["Some error"] } }

        before do
          allow(document).to receive(:valid?).and_return(false)
          allow(document).to receive(:errors).and_return(existing_errors)
        end

        it "returns false" do
          expect(document_with_validator).not_to be_valid
        end

        it "combines its errors with any existing errors" do
          document_with_validator.valid?

          expect(document_with_validator.errors.slice(:field_name))
            .to eq(existing_errors)
        end
      end
    end

    context "when the slug has already been taken" do
      before do
        allow(document_repository).to receive(:slug_unique?)
          .and_return(false)
      end

      it "returns false" do
        expect(document_with_validator).not_to be_valid
      end

      it "adds an error to the slug field" do
        document_with_validator.valid?

        expect(document_with_validator.errors.fetch(:slug))
          .to include("is already taken")
      end

      context "when the document has other errors" do
        let(:existing_errors) { { field_name: ["Some error"] } }

        before do
          allow(document).to receive(:valid?).and_return(false)
          allow(document).to receive(:errors).and_return(existing_errors)
        end

        it "returns false" do
          expect(document_with_validator).not_to be_valid
        end

        it "combines its errors with any existing errors" do
          document_with_validator.valid?

          expect(document_with_validator.errors.slice(:field_name))
            .to eq(existing_errors)
        end
      end
    end

    context "when re-validating after an error state" do
      before do
        allow(document_repository).to receive(:slug_unique?)
          .and_return(false)

        document_with_validator.valid?

        allow(document_repository).to receive(:slug_unique? )
          .and_return(true)
      end

      it "resets the errors each time" do
        expect(document_with_validator).to be_valid
      end
    end
  end
end
