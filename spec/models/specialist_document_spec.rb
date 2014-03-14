require "support/fast_spec_helper"
require "active_support/core_ext/hash"

require "specialist_document"

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
  let(:attachments)         { double(:attachments) }

  let(:edition_messages)    {
    {
      build_attachment: nil,
      assign_attributes: nil,
      version_number: 1,
      attachments: attachments_proxy,
    }
  }

  let(:attachments_proxy) { double(:attachments_proxy, to_a: attachments) }

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
        slug: published_slug,
      )
    )
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

      it "builds a new edition copying over the previous edition's attachements" do
        doc.update(params)

        expect(edition_factory).to have_received(:call).with(hash_including(
          attachments: attachments,
        ))
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

  describe "#add_attachment" do
    let(:editions) { [ published_edition, draft_edition ] }
    let(:params) { double(:params) }

    it "tells the latest edition to create an attachment using the supplied parameters" do
      doc.add_attachment(params)

      expect(draft_edition).to have_received(:build_attachment).with(params)
    end
  end

  describe "#attachments" do
    let(:editions) { [ published_edition, draft_edition ] }

    it "delegates to the latest edition" do
      doc.attachments

      expect(draft_edition).to have_received(:attachments)
    end

    it "returns the attachments from the latest edition" do
      expect(doc.attachments).to eq(attachments)
    end
  end

  describe "#previous_editions" do
    context "with two editions" do
      let(:editions) { [ published_edition, draft_edition ] }

      it "returns an array including the first edition" do
        expect(doc.previous_editions).to eq([published_edition])
      end
    end

    context "with one edition" do
      let(:editions) { [draft_edition] }

      it "returns an empty array" do
        expect(doc.previous_editions).to be_empty
      end
    end
  end

  describe "#attributes" do
    let(:relevant_document_attrs) {
      {
        "title" => "document_title",
      }
    }

    let(:undesirable_edtion_attrs) {
      {
        "junk_key" => "junk_value",
      }
    }

    let(:edition) {
      double(:edition,
        edition_messages.merge(
          attributes: relevant_document_attrs.merge(undesirable_edtion_attrs)
        )
      )
    }

    let(:editions) { [published_edition, edition] }

    it "symbolizes the keys" do
      expect(doc.attributes.keys.map(&:class).uniq).to eq([Symbol])
    end

    it "returns attributes with junk removed" do
      expect(doc.attributes).not_to include(
        undesirable_edtion_attrs.symbolize_keys
      )
    end

    it "returns the latest edition's attributes" do
      expect(doc.attributes).to include(
        relevant_document_attrs.symbolize_keys
      )
    end

    it "returns a has including the document's id" do
      expect(doc.attributes).to include(
        id: document_id,
      )
    end
  end
end
