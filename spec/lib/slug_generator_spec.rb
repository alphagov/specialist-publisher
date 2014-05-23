require "fast_spec_helper"

require "slug_generator"

describe SlugGenerator do
  subject(:slug_gen) {
    SlugGenerator.new(
      prefix: prefix,
    )
  }

  let(:prefix) { "prefix" }
  let(:title) { "My document" }

  describe "#call" do

    it "returns a slug based on the prefix and given title" do
      slug = slug_gen.call(title)

      expect(slug).to eq("prefix/my-document")
    end

    context "when title contains non-word characters" do
      let(:title) { %{Test_ &/Document"1} }

      it "replaces all non-word characters with a single hyphen" do
        slug = slug_gen.call(title)

        expect(slug).to eq("prefix/test-document-1")
      end
    end

    context "when title has non-word characters at the end" do
      let(:title) { "Test Document " }

      it "removes non-word-character—hyphens from the end of the slug" do
        slug = slug_gen.call(title)

        expect(slug).to eq("prefix/test-document")
      end
    end
  end
end
