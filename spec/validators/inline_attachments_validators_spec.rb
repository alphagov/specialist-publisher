require "spec_helper"

RSpec.describe InlineAttachmentsValidator do
  let(:fake_errors_class) do
    Class.new(Hash) do
      def add(attr, message)
        self[attr] ||= []
        self[attr].push(message)
      end
    end
  end

  let(:record) do
    double(
      :record,
      errors: fake_errors_class.new,
      body:,
      attachments: [
        double(:attachment, snippet: "[InlineAttachment:foo.pdf]"),
        double(:attachment, snippet: "[InlineAttachment:bar.pdf]"),
      ],
    )
  end

  subject { described_class.new(attributes: [:body]) }

  context "when there are no inline attachments" do
    let(:body) { "some body" }

    it "validates successfully" do
      subject.validate_each(record, :body, body)
      expect(record.errors[:body]).to be_blank
    end
  end

  context "when all of the inline attachments match" do
    let(:body) { <<-HTML }
      [InlineAttachment:foo.pdf]
      [InlineAttachment:bar.pdf]
    HTML

    it "validates successfully" do
      subject.validate_each(record, :body, body)
      expect(record.errors[:body]).to be_blank
    end
  end

  context "when there are unmatched inline attachments" do
    let(:body) { <<-HTML }
      [InlineAttachment:missing1.pdf]
      [InlineAttachment:foo.pdf]
      [InlineAttachment:missing2.pdf]
      [InlineAttachment:bar.pdf]
      [InlineAttachment:missing1.pdf]
    HTML

    it "adds an error for each unique missing attachment" do
      subject.validate_each(record, :body, body)

      expect(record.errors[:body]).to eq [
        "contains an attachment that can't be found: 'missing1.pdf'",
        "contains an attachment that can't be found: 'missing2.pdf'",
      ]
    end
  end
end
