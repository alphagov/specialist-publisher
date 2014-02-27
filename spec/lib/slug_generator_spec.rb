require 'spec_helper'

describe SlugGenerator do
  it "generates a slug based on the title of a document" do
    document = double("document", title: "My document")

    generated_slug = SlugGenerator.generate_slug(document)

    expect(generated_slug).to eq("cma-cases/my-document")
  end

  it "replaces all non-word characters with a single hyphen" do
    document = double("document", title: 'Test_ &/Document"1')

    generated_slug = SlugGenerator.generate_slug(document)

    expect(generated_slug).to eq("cma-cases/test-document-1")
  end
end
