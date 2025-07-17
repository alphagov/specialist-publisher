require "spec_helper"

RSpec.feature "Searching and filtering by organisation", type: :feature do
  let(:current_user_org_content_id) { "e338f02d-82a3-4c6c-8a36-df3050869d97" }
  let(:org_content_id_two) { "79e140cc-2303-43c2-8c5f-fa41fbf5e319" }
  let(:org_content_id_three) { "aada63d7-c570-4306-9ce2-a2c340d807a1" }
  let(:org_content_id_four) { "728344bc-69b4-4049-bf4b-e58196b82fc8" }
  let!(:request) do
    current_user_org_licence = FactoryBot.create(:licence_transaction,
                                                 title: "Example licence 1",
                                                 primary_publishing_org_content_id: current_user_org_content_id,
                                                 organisation_content_id: org_content_id_two)

    stub_publishing_api_has_content(
      [current_user_org_licence],
      hash_including(document_type: LicenceTransaction.document_type, link_organisations: current_user_org_content_id),
    )
  end

  before do
    organisations = [
      { "title" => "Current users org", "content_id" => current_user_org_content_id },
      { "title" => "Diabolical org", "content_id" => org_content_id_three },
      { "title" => "Excellent org", "content_id" => org_content_id_two },
      { "title" => "Mysterious org", "content_id" => org_content_id_four },
    ]

    stub_publishing_api_has_content(organisations, hash_including(document_type: Organisation.document_type))
    log_in_as_editor(:licence_transaction_editor)
  end

  before(:each) do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:show_design_system, false)
  end

  after(:each) do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:show_design_system, true)
  end

  context "visiting the licence index page without selecting an organisation" do
    scenario "viewing licences from current users organisation" do
      visit "/licences"

      expect(page.status_code).to eq(200)
      expect(request).to have_been_requested
      expect(page).to have_selector("li.document", count: 1)
      expect(page).to have_content("Example licence 1")
      expect(page).to have_select(
        "Organisation",
        selected: "Current users org",
        options: ["All organisations", "Current users org", "Diabolical org", "Excellent org", "Mysterious org"],
      )
    end
  end

  context "visiting the licence index page and selecting an organisation" do
    let!(:second_request) do
      other_org_licence = FactoryBot.create(:licence_transaction,
                                            title: "Example licence 2",
                                            primary_publishing_org_content_id: org_content_id_three,
                                            organisation_content_id: org_content_id_four)

      stub_publishing_api_has_content(
        [other_org_licence],
        hash_including(document_type: LicenceTransaction.document_type, link_organisations: org_content_id_four),
      )
    end

    scenario "viewing licences from selected organisation" do
      visit "/licences"

      select "Mysterious org", from: "Organisation"

      click_button "Search"

      expect(page.status_code).to eq(200)
      expect(second_request).to have_been_requested
      expect(page).to have_select("Organisation", selected: "Mysterious org")
      expect(page).to have_selector("li.document", count: 1)
      expect(page).to have_content("Example licence 2")
    end
  end
end
