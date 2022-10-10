require "spec_helper"

RSpec.describe GovspeakPresenter do
  let(:body) { "Hello, world" }
  let(:attachments) { [] }
  let(:document) { double(:document, body:, attachments:) }
  let(:presented) { described_class.present(document) }

  it "presents the body as multi-type content without adding HTML" do
    expect(presented).to eq [
      { content_type: "text/govspeak", content: "Hello, world" },
    ]
  end

  describe ".presented" do
    let(:expected) { [{ content_type: "text/govspeak", content: }] }

    context "when the document has images as inline attachments" do
      let(:body)        { "![InlineAttachment:foo.jpg]" }
      let(:title)       { "Picture of a tasty-looking pizza" }
      let(:content_id)  { 123 }
      let(:attachments) do
        [instance_double(Attachment, url:, content_id:)]
      end

      context "there is a matching attachment" do
        let(:url) { "http://assets.publishing.service.gov.uk/url/foo.jpg" }
        let(:content) { "[embed:attachments:image:123]" }

        it "replaces InlineAttachment syntax with embed:attachments:image" do
          expect(presented).to eq expected
        end
      end

      context "there is no matching attachment" do
        let(:url) { "http://assets.publishing.service.gov.uk/url/bar.jpg" }
        let(:content) { "[embed:attachments:image:foo.jpg]" }

        it "replaces InlineAttachment syntax and references the filename" do
          expect(presented).to eq expected
        end
      end
    end

    context "when the document has inline attachments" do
      let(:body)        { "[InlineAttachment:foo.pdf]" }
      let(:content_id)  { 123 }
      let(:attachments) do
        [instance_double(Attachment, url:, content_id:)]
      end

      context "there is a matching attachment" do
        let(:url) { "http://assets.publishing.service.gov.uk/url/foo.pdf" }
        let(:content) { "[embed:attachments:inline:123]" }

        it "replaces the InlineAttachment syntax with embed:attachments:inline" do
          expect(presented).to eq expected
        end
      end

      context "there is no matching attachment" do
        let(:url) { "http://assets.publishing.service.gov.uk/url/bar.pdf" }
        let(:content) { "[embed:attachments:inline:foo.pdf]" }

        it "replaces the InlineAttachment syntax and references the filename" do
          expect(presented).to eq expected
        end
      end
    end

    context "when the document has multiple inline attachments" do
      let(:attachments) do
        [
          instance_double(Attachment, url: "falafel.pdf", content_id: 100),
          instance_double(Attachment, url: "tabbouleh.pdf", content_id: 101),
          instance_double(Attachment, url: "babaganoush.jpg", content_id: 102),
        ]
      end
      let(:body) do
        %(
        Here is some body content.
        [InlineAttachment:falafel.pdf]
        [InlineAttachment:tabbouleh.pdf]
        Some extra text, presumably about Levantine foodstuffs.
        ![InlineAttachment:babaganoush.jpg]
        )
      end
      let(:content) do
        %(
        Here is some body content.
        [embed:attachments:inline:100]
        [embed:attachments:inline:101]
        Some extra text, presumably about Levantine foodstuffs.
        [embed:attachments:image:102]
        )
      end

      it "replaces the InlineAttachment syntax" do
        expect(presented).to eq expected
      end
    end
  end

  describe "#snippets_match?" do
    let(:subject) { described_class.new(document) }

    def expect_match(snippet_a, snippet_b)
      expect(subject.snippets_match?(snippet_a, snippet_b))
        .to eq(true),
            "Expected '#{snippet_a}' == '#{snippet_b}'"
    end

    def expect_no_match(snippet_a, snippet_b)
      expect(subject.snippets_match?(snippet_a, snippet_b))
        .to eq(false),
            "Expected '#{snippet_a}' != '#{snippet_b}'"
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
