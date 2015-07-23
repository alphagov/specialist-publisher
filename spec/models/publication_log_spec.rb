require "spec_helper"

describe PublicationLog, hits_db: true do

  describe "validation" do
    let(:attributes) {
      {
        slug: "my-slug",
        title: "my title",
        change_note: "First note",
        version_number: 1
      }
    }

    subject(:publication_log) { PublicationLog.new(attributes) }

    context "all fields set" do
      it { should be_valid }
    end

    it "should be valid without a title" do
      publication_log.title = nil
      expect(publication_log).to be_valid
    end

    it "should be valid without a change_note" do
      publication_log.change_note = nil
      expect(publication_log).to be_valid
    end

    it "should be invalid without a slug" do
      publication_log.slug = nil
      expect(publication_log).not_to be_valid
    end

    it "should be invalid without a version_number" do
      publication_log.version_number = nil
      expect(publication_log).not_to be_valid
    end
  end

  describe ".change_notes_for" do
    context "there are some publication log entries" do
      let(:slug) { "cma-cases/my-slug" }
      let(:other_slug) { "something-else/another-one" }

      let!(:change_notes_for_first_doc) {
        [
          PublicationLog.create(
            slug: slug,
            title: "",
            change_note: "First note",
            version_number: 1,
          ),
          PublicationLog.create(
            slug: slug,
            title: "",
            change_note: "Second note",
            version_number: 2,
          )
        ]
      }

      let!(:change_notes_for_second_doc) {
        [
          PublicationLog.create(
            slug: other_slug,
            title: "",
            change_note: "Another note",
            version_number: 1,
          )
        ]
      }

      it "returns all the change notes for the given slug" do
        expect(PublicationLog.change_notes_for(slug)).to eq(change_notes_for_first_doc)
      end

      context "multiple publication logs exist for a particular edition version" do
        before do
          PublicationLog.create(
            slug: slug,
            title: "",
            change_note: "Duplicate note",
            version_number: 2,
          )
        end

        it "removes duplicates" do
          expect(PublicationLog.change_notes_for(slug)).to eq(change_notes_for_first_doc)
        end
      end
    end

    context "no publication logs exist for a slug" do
      it "returns an empty list" do
        expect(PublicationLog.change_notes_for("cma-cases/my-slug")).to eq([])
      end
    end
  end
end
