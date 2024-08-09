require "spec_helper"

RSpec.describe DocumentLinksPresenter do
  it "presents links for document" do
    document = StatutoryInstrument.new
    allow(document).to receive(:primary_publishing_organisation).and_return("an-organisation-id")

    presenter = DocumentLinksPresenter.new(document)
    presented_data = presenter.to_json

    expect(presented_data[:links][:primary_publishing_organisation]).to eq(%w[an-organisation-id])
  end

  it "expects the brexit taxon to be returned if the document type is Statutory Instrument" do
    document = StatutoryInstrument.new

    links_presenter = DocumentLinksPresenter.new(document)
    presented_data = links_presenter.to_json

    expect(presented_data[:links][:taxons]).to eq(%w[d6c2de5d-ef90-45d1-82d4-5f2438369eea])
  end
end
