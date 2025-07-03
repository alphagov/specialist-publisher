require "spec_helper"

RSpec.feature "Searching and filtering by organisation", type: :feature do
  let(:current_user_org) do
    { "title" => "Current users org", "content_id" => "e338f02d-82a3-4c6c-8a36-df3050869d97" }
  end
  let(:selected_org) do
    { "title" => "Selected org", "content_id" => "728344bc-69b4-4049-bf4b-e58196b82fc8" }
  end
  let(:additional_org) do
    { "title" => "Another org", "content_id" => "79e140cc-2303-43c2-8c5f-fa41fbf5e319" }
  end
  let(:all_organisations) { [current_user_org, selected_org, additional_org] }
  let(:current_user_org_licence) do
    FactoryBot.create(:licence_transaction,
                      title: "Example licence 1",
                      primary_publishing_org_content_id: current_user_org["content_id"],
                      organisation_content_id: additional_org["content_id"])
  end
  let!(:request) do
    stub_publishing_api_has_content(
      [current_user_org_licence],
      hash_including(document_type: LicenceTransaction.document_type, link_organisations: current_user_org["content_id"]),
    )
  end

  before do
    stub_publishing_api_has_content(all_organisations, hash_including(document_type: Organisation.document_type))
    log_in_as_design_system_editor(:licence_transaction_editor)
  end

  context "visiting the licence index page without selecting an organisation" do
    scenario "shows only licences from current user's organisation" do
      visit "/licences"

      expect(page.status_code).to eq(200)
      expect(request).to have_been_requested
      expect(page).to have_select(
        "Organisation",
        selected: current_user_org["title"],
        options: all_organisations.map { |org| org["title"] }.prepend("All organisations"),
      )
      expect(page).to have_selector("tr", count: 2) # Header row + one licence row
      expect(page).to have_selector("tr", text: current_user_org_licence["title"], count: 1)
    end
  end

  context "visiting the licence index page and selecting 'All organisations'" do
    let(:additional_org_licence) do
      FactoryBot.create(:licence_transaction,
                        title: "Example licence 2",
                        primary_publishing_org_content_id: additional_org["content_id"],
                        organisation_content_id: current_user_org["content_id"])
    end
    let!(:filter_request) do
      stub_publishing_api_has_content(
        [current_user_org_licence, additional_org_licence],
        hash_including(document_type: LicenceTransaction.document_type),
      )
    end

    scenario "shows all licences from all organisations" do
      visit "/licences"

      select "All organisations", from: "Organisation"
      click_button "Filter"

      expect(page.status_code).to eq(200)
      expect(filter_request).to have_been_requested.at_least_once
      expect(page).to have_select("Organisation", selected: [])
      expect(page).to have_selector("tr", count: 3) # Header row + two licence rows
      expect(page).to have_selector("tr", text: current_user_org_licence["title"], count: 1)
      expect(page).to have_selector("tr", text: additional_org_licence["title"], count: 1)
    end
  end

  context "visiting the licence index page and selecting an organisation" do
    let(:licence_with_selected_org_as_primary) do
      FactoryBot.create(:licence_transaction,
                        title: "Example licence 2",
                        primary_publishing_org_content_id: selected_org["content_id"],
                        organisation_content_id: additional_org["content_id"])
    end
    let(:licence_with_selected_org_as_other) do
      FactoryBot.create(:licence_transaction,
                        title: "Example licence 3",
                        primary_publishing_org_content_id: additional_org["content_id"],
                        organisation_content_id: selected_org["content_id"])
    end
    let!(:filter_request) do
      stub_publishing_api_has_content(
        [licence_with_selected_org_as_primary, licence_with_selected_org_as_other],
        hash_including(document_type: LicenceTransaction.document_type, link_organisations: selected_org["content_id"]),
      )
    end

    scenario "shows only licences from selected organisation" do
      visit "/licences"

      select selected_org["title"], from: "Organisation"
      click_button "Filter"

      expect(page.status_code).to eq(200)
      expect(filter_request).to have_been_requested
      expect(page).to have_select("Organisation", selected: selected_org["title"])
      expect(page).to have_selector("tr", count: 3) # Header row + one licence row
      expect(page).to have_selector("tr", text: licence_with_selected_org_as_primary["title"], count: 1)
      expect(page).to have_selector("tr", text: licence_with_selected_org_as_other["title"], count: 1)
    end
  end

  context "visiting the licence index page and filtering by organisation and title" do
    let(:licence_with_selected_org_as_primary) do
      FactoryBot.create(:licence_transaction,
                        title: "Example licence 2",
                        primary_publishing_org_content_id: selected_org["content_id"],
                        organisation_content_id: additional_org["content_id"])
    end
    let(:licence_with_selected_org_as_other) do
      FactoryBot.create(:licence_transaction,
                        title: "Example licence 3 KEYWORD MATCH",
                        primary_publishing_org_content_id: additional_org["content_id"],
                        organisation_content_id: selected_org["content_id"])
    end
    let!(:filter_request) do
      stub_publishing_api_has_content(
        [licence_with_selected_org_as_other],
        hash_including(document_type: LicenceTransaction.document_type, link_organisations: selected_org["content_id"], q: "KEYWORD MATCH"),
      )
    end

    scenario "shows only licences from selected organisation that match the title filter" do
      visit "/licences"

      select selected_org["title"], from: "Organisation"
      fill_in "Title", with: "KEYWORD MATCH"
      click_button "Filter"

      expect(page.status_code).to eq(200)
      expect(filter_request).to have_been_requested
      expect(page).to have_select("Organisation", selected: selected_org["title"])
      expect(page).to have_selector("tr", count: 2) # Header row + one licence row
      expect(page).to have_selector("tr", text: licence_with_selected_org_as_other["title"], count: 1)
      expect(page).to have_selector("tr", text: licence_with_selected_org_as_primary["title"], count: 0)
    end
  end
end
