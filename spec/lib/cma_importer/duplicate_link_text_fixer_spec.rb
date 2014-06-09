require "spec_helper"
require "cma_importer/duplicate_link_text_fixer"

describe CMAImporter::DuplicateLinkTextFixer do
  describe ".dedupe(edition)" do
    before(:all) do
      a1 = Attachment.new(title: "Basic duplicate", filename: "basic_dupe.pdf")
      a2 = Attachment.new(title: "Something else", filename: "non_dupe.pdf")
      a3 = Attachment.new(title: "duplicate text", filename: "dupe_text.pdf")
      a4 = Attachment.new(title: "newline\n text", filename: "newline_text.pdf")

      @edition = FactoryGirl.create(:specialist_document_edition,
        body: "* Basic duplicate [InlineAttachment:basic_dupe.pdf]
               * Not a dupe [InlineAttachment:non_dupe.pdf]
               * Stuff then duplicate text [InlineAttachment:dupe_text.pdf]
               * newline\n text [InlineAttachment:newline_text.pdf]",
        attachments: [a1, a2, a3, a4],
        document_id: "123"
      )

      CMAImporter::DuplicateLinkTextFixer.dedupe(@edition)
      @edition.reload
    end

    it "removes duplicate text preceding a link" do
      expect(@edition.body).to include("* [InlineAttachment:basic_dupe.pdf]")
    end

    it "leaves non-duplicate text alone"do
      expect(@edition.body).to include("* Not a dupe [InlineAttachment:non_dupe.pdf]")
    end

    it "leaves text before the duplicates alone"do
      expect(@edition.body).to include("* Stuff then [InlineAttachment:dupe_text.pdf]")
    end

    it "removes duplicates even with extra newlines" do
      expect(@edition.body).to include("* [InlineAttachment:newline_text.pdf]")
    end
  end
end
