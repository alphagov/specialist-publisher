require 'spec_helper'

describe SpecialistDocument do
  subject(:doc) {
    SpecialistDocument.new(slug_generator, edition_factory, document_id, editions)
  }

  let(:document_id)         { "a-document-id" }
  let(:slug)                { double(:slug) }
  let(:published_slug)      { double(:published_slug) }
  let(:slug_generator)      { double(:slug_generator, call: slug) }
  let(:edition_factory)     { double(:edition_factory, call: new_edition) }
  let(:new_edition)         { double(:new_edition, published?: false, assign_attributes: nil) }

  let(:draft_edition)       {
    double(:draft_edition,
      edition_messages.merge(
        draft?: true,
        published?: false,
      )
    )
  }

  let(:published_edition)   {
    double(:published_edition,
      edition_messages.merge(
        published?: true,
        draft?: false,
      )
    )
  }

  let(:edition_messages) {
    {
      published?: true,
      draft?: false,
      slug: published_slug,
      version_number: 1,
      assign_attributes: nil,
    }
  }

  context "document is new, with no previous editions" do
    let(:editions) { [] }
    let(:attrs)    { { title: "Test title" } }

    describe "#udpate" do
      it "creates the first edition" do
        doc.update(attrs)

        expect(edition_factory).to have_received(:call).with(
          version_number: 1,
          state: "draft",
        )
      end
    end
  end

  context "with one draft edition" do
    let(:editions) { [ draft_edition ] }

    it "is in draft" do
      expect(doc).to be_draft
    end

    it "is not published" do
      expect(doc).not_to be_published
    end
  end

  context "with one published edition" do
    let(:editions) { [ published_edition ] }

    it "is published" do
      expect(doc).to be_published
    end

    it "is not in draft" do
      expect(doc).not_to be_draft
    end
  end

  context "with one published edition and one draft edition" do
    let(:editions) { [ published_edition, draft_edition ] }

    it "is published and in draft" do
      expect(doc).to be_draft
      expect(doc).to be_published
    end
  end

  describe "#update" do
    context "before the document is published" do
      context "with an existing draft edition" do
        let(:editions)  { [draft_edition] }

        context "when providing a title" do
          let(:new_title) { double(:new_title) }
          let(:slug)      { double(:slug) }

          it "generates a slug" do
            doc.update(title: new_title)

            expect(slug_generator).to have_received(:call).with(new_title)
          end

          it "assigns the title and slug to the draft edition" do
            doc.update(title: new_title)

            expect(draft_edition).to have_received(:assign_attributes)
              .with(hash_including(
                title: new_title,
                slug: slug,
              ))
          end
        end
      end
    end

    context "when the document is published" do
      let(:editions) { [published_edition] }

      let(:params) { {title: "It is a new title"} }

      it "builds a new edition with the new params" do
        doc.update(params)

        expect(edition_factory).to have_received(:call).with(hash_including(params))
      end

      it "builds a new edition with an incremented version number" do
        doc.update(params)

        expect(edition_factory).to have_received(:call).with(hash_including(version_number: 2))
      end

      it "builds a new edition in the 'draft' state" do
        doc.update(params)

        expect(edition_factory).to have_received(:call).with(hash_including(state: 'draft'))
      end

      it "presents the new edition as the latest" do
        doc.update(params)

        expect(doc.latest_edition).to eq(new_edition)
      end

      it "returns self" do
        expect(doc.update(params)).to eq(doc)
      end

      context "when providing a title" do
        let(:new_title) { double(:new_title) }
        let(:slug)      { double(:slug) }

        it "does not update the slug" do
          doc.update(title: new_title)

          expect(edition_factory).to have_received(:call).with(
            hash_including(
              :slug => published_slug,
            )
          )
        end
      end
    end
  end
end
