require "spec_helper"

RSpec.describe DocumentsTagger do
  before :each do
    @content_id = SecureRandom.uuid

    stub_const(
      "DocumentTypeOne",
      Class.new do
        def taxons
          %w[mapped_taxon_id]
        end
      end,
    )

    stub_const(
      "DocumentTypeTwo",
      Class.new do
        def taxons
          []
        end
      end,
    )

    allow(FinderSchema).to receive(:schema_names).and_return(%w[document_type_one document_type_two])
  end

  it "automatically tags a document" do
    get_content_items_enum_returns(["base_path" => "/base_path", "content_id" => @content_id, "document_type" => "document_type_one"])
    expect(Tagger).to receive(:add_tags).with(@content_id, do_tag: true).and_yield(%w[mapped_taxon_id]).and_return(true)
    expect(DocumentsTagger.tag_all(do_tag: true).to_a).to eq([{ base_path: "/base_path", content_id: @content_id, taxons: %w[mapped_taxon_id] }])
  end

  it "does not tag the documents because the do_tag option is set to false - it does return potentially tagged taxons" do
    get_content_items_enum_returns(["base_path" => "/base_path", "content_id" => @content_id, "document_type" => "document_type_one"])
    expect(Tagger).to receive(:add_tags).with(@content_id, do_tag: false).and_yield(%w[mapped_taxon_id]).and_return(true)
    expect(DocumentsTagger.tag_all(do_tag: false).to_a).to eq([{ base_path: "/base_path", content_id: @content_id, taxons: %w[mapped_taxon_id] }])
  end

  it "does not tag a document because it has already been tagged" do
    get_content_items_enum_returns(["base_path" => "/base_path", "content_id" => @content_id, "document_type" => "document_type_one"])
    expect(Tagger).to receive(:add_tags).with(@content_id, do_tag: true).and_yield(%w[mapped_taxon_id]).and_return(false)
    expect(DocumentsTagger.tag_all(do_tag: true).to_a).to eq([{ base_path: "/base_path", content_id: @content_id, taxons: [] }])
  end

  it "Does not tag documents - or invoke tagging logic - because the mapping does not specify a taxon to tag" do
    get_content_items_enum_returns(["base_path" => "/base_path", "content_id" => @content_id, "document_type" => "document_type_two"])
    expect(Tagger).to receive(:add_tags).never
    expect(DocumentsTagger.tag_all.to_a).to eq([{ base_path: "/base_path", content_id: @content_id, taxons: [] }])
  end

  def get_content_items_enum_returns(return_value)
    allow(Services.publishing_api).to receive(:get_paged_editions).with(
      hash_including(document_types: %w[document_type_one document_type_two]),
    ).and_return([{ "results" => return_value }].to_enum)
  end
end
