require "spec_helper"
require "importers/licence_transaction/facet_tagger"

RSpec.describe Importers::LicenceTransaction::FacetTagger do
  describe "#tag" do
    let(:licence_identifier) { "9150-7-1" }
    let(:licence_transaction) { FactoryBot.build(:licence_transaction_model, licence_transaction_licence_identifier: licence_identifier) }

    before do
      stub_request(:get, "#{Plek.website_root}/licence-finder/licences-api")
        .to_return(status: 200, body: licence_finder_api_response.to_json)
    end

    it "tags imported locations to licence" do
      described_class.new(licence_transaction).tag

      expect(licence_transaction.licence_transaction_location)
        .to match_array(%w[
          england
          wales
          scotland
          northern-ireland
        ])
    end

    it "tags imported industries to licence" do
      described_class.new(licence_transaction).tag
      expect(licence_transaction.licence_transaction_industry)
        .to match_array(%w[
          arts-and-entertainment
          accommodation
        ])
    end
  end

  def licence_finder_api_response
    [
      {
        "licence_identifier": licence_identifier,
        "locations": %w[
          england
          wales
          scotland
          northern-ireland
        ],
        "industry_sectors": %w[
          arts-and-entertainment
          accommodation
        ],
      },
    ]
  end
end
