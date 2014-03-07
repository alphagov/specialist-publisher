require 'spec_helper'

describe SlugGenerator do
  let(:title) { "My document" }

  it "generates a slug based on the title of a document" do
    generated_slug = SlugGenerator.call(title)

    expect(generated_slug).to eq("cma-cases/my-document")
  end

  context "when title contains non-word characters" do
    let(:title) { %{Test_ &/Document"1} }

    it "replaces all non-word characters with a single hyphen" do
      generated_slug = SlugGenerator.call(title)

      expect(generated_slug).to eq("cma-cases/test-document-1")
    end
  end

  context "when title has non-word characters at the end" do
    let(:title) { "Test Document " }

    it "removes non-word-character—hyphens from the end of the slug" do
      generated_slug = SlugGenerator.call(title)

      expect(generated_slug).to eq("cma-cases/test-document")
    end
  end
end
