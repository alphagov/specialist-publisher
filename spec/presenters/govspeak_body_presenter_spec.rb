require "spec_helper"

RSpec.describe GovspeakBodyPresenter do
  describe "#present" do
    let(:document) { double(:document, body:, attachments:) }
    subject { described_class.present(document) }

    shared_examples "handles filename quirks" do |input_pattern, output_pattern|
      let(:content_id) { "1ef8" }
      let(:input_filename) { "foo.pdf" }
      let(:file_path) { "/foo.pdf" }
      let(:url) { "https://assets.publishing.service.gov.uk#{file_path}" }
      let(:attachments) { [instance_double(Attachment, url:, content_id:)] }
      let(:fallback_output) { sprintf(output_pattern, input_filename) }
      let(:successful_output) { sprintf(output_pattern, content_id) }
      let(:body) { sprintf(input_pattern, input_filename) }

      context "when the filenames differ" do
        let(:file_path) { "/foo.pdf" }
        it { is_expected.to eq(successful_output) }
      end

      context "when the filenames differ" do
        let(:file_path) { "/bar.pdf" }
        it { is_expected.to eq(fallback_output) }
      end

      context "when the extensions differ" do
        let(:file_path) { "foo.jpg" }
        it { is_expected.to eq(fallback_output) }
      end

      context "when the filename has spaces" do
        let(:input_filename) { "f oo.pdf" }
        let(:file_path) { "/f oo.pdf" }
        it { is_expected.to eq(successful_output) }
      end

      context "when there are non alphanumeric characters" do
        let(:input_filename) { "f@oo.pdf" }
        let(:file_path) { "/f&oo.pdf" }
        it "matches on alphanumeric characters only" do
          is_expected.to eq(successful_output)
        end
      end

      context "when the file is in a directory" do
        let(:file_path) { "/path/to/foo.pdf" }
        it "matches on the filename" do
          is_expected.to eq(successful_output)
        end
      end

      context "when the attachment is specified as in a directory" do
        let(:input_filename) { "path/to/foo.pdf" }
        it "matches on the filename" do
          is_expected.to eq(successful_output)
        end
      end

      context "when the input filename contains CGI escaped characters" do
        let(:input_filename) { "%282016%20File%29.pdf" }
        let(:file_path) { "/(2016 File).pdf" }
        it "unescapes the characters" do
          is_expected.to eq(successful_output)
        end
      end

      context "when there are spaces around the filename" do
        let(:input_filename) { " foo.pdf " }
        it "ignores the spaces" do
          is_expected.to eq(successful_output)
        end
      end

      context "when the file names are in different cases" do
        let(:input_filename) { "FOO.PDF" }
        it "ignores the casing" do
          is_expected.to eq(successful_output)
        end
      end
    end

    context "when the document has image attachments" do
      include_examples "handles filename quirks",
                       "![InlineAttachment:%s]",
                       "[embed:attachments:image:%s]"
    end

    context "when the document has inline attachments" do
      include_examples "handles filename quirks",
                       "[InlineAttachment:%s]",
                       "[embed:attachments:inline:%s]"
    end
  end
end
