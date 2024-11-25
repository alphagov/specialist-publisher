require "rails_helper"

RSpec.describe "licence_reports", type: :task do
  describe "licence_reports:all" do
    let(:task) { Rake::Task["licence_reports:all"] }
    before(:each) { task.reenable }

    let(:licence_transaction) do
      lt = FactoryBot.create(:licence_transaction)
      lt["details"]["metadata"]["licence_transaction_location"] = %w[england wales]
      lt
    end
    let(:content_id) { licence_transaction["content_id"] }
    let(:organisations) do
      [
        { "content_id" => "6de6b795-9d30-4bd8-a257-ab9a6879e1ea", "title" => "PPO Org" },
        { "content_id" => "d31d9806-2644-4023-be70-5376cae84a06", "title" => "Other Org" },
      ]
    end

    before do
      stub_publishing_api_has_content([licence_transaction], hash_including(document_type: LicenceTransaction.document_type))
      stub_publishing_api_has_item(licence_transaction)
      stub_publishing_api_has_content(organisations, hash_including(document_type: Organisation.document_type))
    end

    it "reports on licences" do
      expect { task.invoke }.to output(
        "title,link_to_competent_authority,licence_identifier,location,publishing_organisation,other_associated_organisations,publication_state,last_updated_at\n" \
        "Example document,https://www.gov.uk,,england / wales,Other Org,PPO Org,draft,2015-11-16T11:53:30+00:00\n",
      ).to_stdout
    end
  end
end
