require 'spec_helper'

RSpec.describe GovspeakPresenter do
  let(:body) { "Hello, world" }
  let(:attachments) { [] }
  let(:document) { double(:document, body: body, attachments: attachments) }
  let(:presented) { described_class.present(document) }

  it "presents the body as multi-type content" do
    expect(presented).to eq [
      { content_type: "text/govspeak", content: "Hello, world" },
      { content_type: "text/html", content: "<p>Hello, world</p>\n" },
    ]
  end

  context "when the document has inline attachments" do
    let(:snippet) { "[InlineAttachment:foo.pdf]" }
    let(:url) { "http://assets.publishing.service.gov.uk/url/foo.pdf" }
    let(:attachment) {
      double(:attachment, snippet: snippet, title: "Foo", url: url)
    }

    let(:body) { snippet }
    let(:attachments) { [attachment] }

    it "replaces the snippet with an anchor and no rel='external' tag" do
      expect(presented).to eq [
        { content_type: "text/govspeak", content: snippet },
        { content_type: "text/html",
          content: %(<p><a href="http://assets.publishing.service.gov.uk/url/foo.pdf">Foo</a></p>\n) }
      ]
    end
  end

  context "when the document has external links and a protocol (i.e. HTTP:)" do
    let(:body) { "[External Link with protocol](https://something.external.uk/url/foo.pdf)" }

    it "adds rel='external' to anchor tag for non-whitelisted hosts" do
      expect(presented).to eq [
                                  { content_type: "text/govspeak", content: body },
                                  { content_type: "text/html",
                                    content: %(<p><a rel="external" href="https://something.external.uk/url/foo.pdf">External Link with protocol</a></p>\n) }]
    end
  end

  context "when the document has external links and no protocol" do
    let(:body) { "[External Link without protocol](something.external.uk/url/foo.pdf)" }

    it "does not adds rel='external' to anchor tag" do
      expect(presented).to eq [
                                  { content_type: "text/govspeak", content: body },
                                  { content_type: "text/html",
                                    content: %(<p><a href="something.external.uk/url/foo.pdf">External Link without protocol</a></p>\n) }]
    end
  end

  context "when the document has internal links with a protocol (i.e. HTTP:)" do
    let(:body) { "[Internal Link with protocol](http://www.gov.uk/url/foo.pdf)" }

    it "does not adds rel='external' to anchor tag" do
      expect(presented).to eq [
                                  { content_type: "text/govspeak", content: body },
                                  { content_type: "text/html",
                                    content: %(<p><a href="http://www.gov.uk/url/foo.pdf">Internal Link with protocol</a></p>\n) }]
    end
  end

  context "when the document has internal links and no protocol" do
    let(:body) { "[Internal Link without protocol](www.gov.uk/url/foo.pdf)" }

    it "does not adds rel='external' to anchor tag" do
      expect(presented).to eq [
                                  { content_type: "text/govspeak", content: body },
                                  { content_type: "text/html",
                                    content: %(<p><a href="www.gov.uk/url/foo.pdf">Internal Link without protocol</a></p>\n) }]
    end
  end

  describe "#snippets_match?" do
    let(:subject) { described_class.new(document) }

    def expect_match(a, b)
      expect(subject.snippets_match?(a, b)).to eq(true),
        "Expected '#{a}' == '#{b}'"
    end

    def expect_no_match(a, b)
      expect(subject.snippets_match?(a, b)).to eq(false),
        "Expected '#{a}' != '#{b}'"
    end

    it "matches on identical strings" do
      expect_match("[InlineAttachment:foo.pdf]", "[InlineAttachment:foo.pdf]")
    end

    it "does not match if the filenames differ" do
      expect_no_match("[InlineAttachment:foo.pdf]", "[InlineAttachment:bar.pdf]")
      expect_no_match("[InlineAttachment:foo.pdf]", "[InlineAttachment:fooo.pdf]")
    end

    it "does not match if the extensions differ" do
      expect_no_match("[InlineAttachment:foo.pdf]", "[InlineAttachment:foo.png]")
      expect_no_match("[InlineAttachment:foo.pdf]", "[InlineAttachment:foo.txt]")
    end

    it "treats all special characters as the same character" do
      expect_match("[InlineAttachment:foo!.pdf]", "[InlineAttachment:foo@.pdf]")
      expect_match("[InlineAttachment:foo&.pdf]", "[InlineAttachment:foo%.pdf]")
      expect_match("[InlineAttachment:f-oo.pdf]", "[InlineAttachment:f_oo.pdf]")
      expect_match("[InlineAttachment:f oo.pdf]", "[InlineAttachment:f&oo.pdf]")
      expect_match("[InlineAttachment:f oo.pdf]", "[InlineAttachment:f oo.pdf]")

      expect_no_match("[InlineAttachment:foo-.pdf]", "[InlineAttachment:f_oo.pdf]")
      expect_no_match("[InlineAttachment:fooo.pdf]", "[InlineAttachment:foo_.pdf]")
    end

    it "matches on the filename only, not the absolute path" do
      expect_match("[InlineAttachment:x/foo.pdf]", "[InlineAttachment:foo.pdf]")
      expect_match("[InlineAttachment:/foo.pdf]", "[InlineAttachment:foo.pdf]")
      expect_match("[InlineAttachment:x/y/foo.pdf]", "[InlineAttachment:foo.pdf]")
      expect_match("[InlineAttachment:x/foo.pdf]", "[InlineAttachment:y/foo.pdf]")
      expect_match("[InlineAttachment:x/y/foo.pdf]", "[InlineAttachment:z/w/foo.pdf]")
      expect_match("[InlineAttachment:/x/y/foo.pdf]", "[InlineAttachment:y/foo.pdf]")

      expect_no_match("[InlineAttachment:foo/x.pdf]", "[InlineAttachment:x/foo.pdf]")
      expect_no_match("[InlineAttachment:x/y.pdf]", "[InlineAttachment:x/y/foo.pdf]")
    end

    it "matches urls with CGI escaped character sequences" do
      expect_match("[InlineAttachment:foo%20bar.pdf]", "[InlineAttachment:foo bar.pdf]")
      expect_match("[InlineAttachment:%282016%29.pdf]", "[InlineAttachment:(2016).pdf]")
      expect_match("[InlineAttachment:foo.pdf%20]", "[InlineAttachment:foo.pdf]")
      expect_match("[InlineAttachment:x%2Ffoo.pdf]", "[InlineAttachment:foo.pdf]")

      expect_no_match("[InlineAttachment:foo%28.pdf]", "[InlineAttachment:foo___.pdf]")
    end

    it "ignores whitespace between words" do
      expect_match("[ InlineAttachment:foo.pdf]", "[InlineAttachment:foo.pdf]")
      expect_match("[InlineAttachment :foo.pdf]", "[InlineAttachment:foo.pdf]")
      expect_match("[InlineAttachment: foo.pdf]", "[InlineAttachment:foo.pdf]")
      expect_match("[InlineAttachment:foo.pdf ]", "[InlineAttachment:foo.pdf]")
      expect_match("[ InlineAttachment : foo.pdf ]", "[InlineAttachment:foo.pdf]")

      expect_no_match("[Inline Attachment:foo.pdf]", "[InlineAttachment:foo.pdf]")
      expect_no_match("[InlineAttachment:fo o.pdf]", "[InlineAttachment:foo.pdf]")
      expect_no_match("[InlineAttachment:foo .pdf]", "[InlineAttachment:foo.pdf]")
      expect_no_match("[InlineAttachment:foo. pdf]", "[InlineAttachment:foo.pdf]")
      expect_no_match("[InlineAttachment:foo.pd f]", "[InlineAttachment:foo.pdf]")
    end

    it "ignores case in the filename" do
      expect_match("[InlineAttachment:FOO.pdf]", "[InlineAttachment:foo.pdf]")
      expect_match("[InlineAttachment:foo.PDF]", "[InlineAttachment:foo.pdf]")
      expect_match("[InlineAttachment:FOO.PDF]", "[InlineAttachment:foo.pdf]")

      expect_no_match("[INLINEATTACHMENT:foo.pdf]", "[InlineAttachment:foo.pdf]")
    end

    it "returns false for garbage input, even if it's the same" do
      expect_no_match("garbage", "][[]!@£$")
      expect_no_match("garbage", "garbage")
      expect_no_match("", "")
    end
  end
end
