require "spec_helper"

RSpec.describe AttachmentReporter do
  let(:document) { double(:document, body: <<-HTML, attachments:) }
    # Testing #{described_class}

    This body uses inline attachmments:
      [InlineAttachment:foo.pdf]

    Some of the attachments are referenced more than once:
      [InlineAttachment:bar.pdf]
      [InlineAttachment:bar.pdf]
      [InlineAttachment:baz-1.pdf]
      [InlineAttachment:baz-1.pdf]
      [InlineAttachment:baz-1.pdf]

    This one is used, but is missing from the document:
      [InlineAttachment:missing.pdf]
      [InlineAttachment:missing.pdf]

    There's another on the document (unused.pdf) that we're not going to use.
  HTML

  let(:attachments) do
    [
      double(:attachment, snippet: "[InlineAttachment:foo.pdf]"),
      double(:attachment, snippet: "[InlineAttachment:bar.pdf]"),
      double(:attachment, snippet: "[InlineAttachment:baz-1.pdf]"),
      double(:attachment, snippet: "[InlineAttachment:baz_1.pdf]"),
      double(:attachment, snippet: "[InlineAttachment:unused.pdf]"),
    ]
  end

  let(:report) { described_class.report(document) }

  it "builds a report of attachments, with respect to the document's body" do
    expect(report).to eq(
      attachment_counts: {
        used: 3,
        unused: 2,
      },
      snippet_counts: {
        matched: 6,
        unmatched: 2,
      },
      unused_attachments: %w[baz_1.pdf unused.pdf],
      unmatched_snippets: %w[missing.pdf missing.pdf],
    )
  end
end
