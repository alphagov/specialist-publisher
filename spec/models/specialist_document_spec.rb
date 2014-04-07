require "fast_spec_helper"
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
  let(:new_edition)         { double(:new_edition, published?: false, assign_attributes: nil, version_number: 2) }
  let(:attachments)         { double(:attachments) }

  let(:edition_messages)    {
    {
      build_attachment: nil,
      assign_attributes: nil,
      attachments: attachments_proxy,
      publish: nil,
    }
  }

  let(:attachments_proxy) { double(:attachments_proxy, to_a: attachments) }

  let(:draft_edition_v1) {
    double(:draft_edition_v1,
      edition_messages.merge(
        title: "Draft edition v1",
        draft?: true,
        published?: false,
        version_number: 1,
      )
    )
  }

  let(:draft_edition_v2) {
    double(:draft_edition_v2,
      edition_messages.merge(
        title: "Draft edition v2",
        draft?: true,
        published?: false,
        version_number: 2,
      )
    )
  }

  let(:published_edition_v1) {
    double(:published_edition_v1,
      edition_messages.merge(
        title: "Published edition",
        published?: true,
        draft?: false,
        slug: published_slug,
        version_number: 1,
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
    let(:editions) { [ draft_edition_v1 ] }

    it "is in draft" do
      expect(doc).to be_draft
    end

    it "is not published" do
      expect(doc).not_to be_published
    end
  end

  context "with one published edition" do
    let(:editions) { [ published_edition_v1 ] }

    it "is published" do
      expect(doc).to be_published
    end

    it "is not in draft" do
      expect(doc).not_to be_draft
    end
  end

  context "with one published edition and one draft edition" do
    let(:editions) { [ published_edition_v1, draft_edition_v2 ] }

    it "is published and in draft" do
      expect(doc).to be_draft
      expect(doc).to be_published
    end

    it "can be instantiated as the published edition" do
      expect(doc.published_version.title).to eq(published_edition_v1.title)
      expect(doc.published_version.version_number).to eq(published_edition_v1.version_number)
    end
  end

  describe "#update" do
    context "before the document is published" do
      context "with an existing draft edition" do
        let(:editions)  { [draft_edition_v1] }

        context "when providing a title" do
          let(:new_title) { double(:new_title) }
          let(:slug)      { double(:slug) }

          it "generates a slug" do
            doc.update(title: new_title)

            expect(slug_generator).to have_received(:call).with(new_title)
          end

          it "assigns the title and slug to the draft edition" do
            doc.update(title: new_title)

            expect(draft_edition_v1).to have_received(:assign_attributes)
              .with(hash_including(
                title: new_title,
                slug: slug,
              ))
          end
        end
      end
    end

    context "when the current document is published" do
      let(:editions) { [published_edition_v1] }

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

      it "presents the new edition" do
        doc.update(params)

        expect(doc.version_number).to eq(new_edition.version_number)
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

    context "with a published and draft edition, published edition exposed" do
      let(:editions) { [published_edition_v1, draft_edition_v2] }
      let(:doc_with_published_edition_exposed) {
        doc.published_version
      }

      it "raises" do
        expect { doc_with_published_edition_exposed.update({title: "blah"}) }.to raise_error
      end
    end

  end

  describe "#publish!" do
    context "one draft" do
      let(:editions) { [ draft_edition_v1 ] }

      it "should set its state to published" do
        doc.publish!
        expect(draft_edition_v1).to have_received(:publish)
      end
    end

    context "one published and one draft edition" do
      let(:editions) { [ published_edition_v1, draft_edition_v2 ] }

      it "should set the draft edition's state to published" do
        doc.publish!
        expect(draft_edition_v2).to have_received(:publish)
      end

      context "when the published edition is exposed" do
        it "should raise an exception" do
          expect {
            doc.published_version.publish!
          }.to raise_error
        end
      end
    end

    context "one published edition" do
      let(:editions) { [ published_edition_v1] }

      it "do nothing" do
        doc.publish!
        expect(published_edition_v1).not_to have_received(:publish)
      end
    end
  end

  describe "#add_attachment" do
    let(:editions) { [ published_edition_v1, draft_edition_v2 ] }
    let(:params) { double(:params) }

    it "tells the latest edition to create an attachment using the supplied parameters" do
      doc.add_attachment(params)

      expect(draft_edition_v2).to have_received(:build_attachment).with(params)
    end
  end

  describe "#attachments" do
    let(:editions) { [ published_edition_v1, draft_edition_v2 ] }

    it "delegates to the latest edition" do
      doc.attachments

      expect(draft_edition_v2).to have_received(:attachments)
    end

    it "returns the attachments from the latest edition" do
      expect(doc.attachments).to eq(attachments)
    end
  end

  describe "#previous_editions" do
    context "with two editions" do
      let(:editions) { [ published_edition_v1, draft_edition_v2 ] }

      it "returns an array including the first edition" do
        expect(doc.previous_editions).to eq([published_edition_v1])
      end
    end

    context "with one edition" do
      let(:editions) { [draft_edition_v1] }

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
      draft_edition_v2.tap do |e|
        allow(e).to receive(:attributes).and_return(relevant_document_attrs.merge(undesirable_edtion_attrs))
      end
    }

    let(:editions) { [published_edition_v1, edition] }

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

  describe "#finder_slug" do
    let(:editions) { [published_edition_v1] }
    let(:published_slug) { "finder-791/some-document" }

    it "uses the first part of the slug" do
      expect(doc.finder_slug).to eq("finder-791")
    end
  end
end
