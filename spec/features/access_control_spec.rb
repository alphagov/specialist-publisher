require 'spec_helper'

RSpec.feature "Access control", type: :feature do
  let(:manual_fields) { %i[content_id description title details public_updated_at publication_state base_path update_type] }

  before do
    publishing_api_has_content([], hash_including(document_type: CmaCase.document_type))
    publishing_api_has_content([], hash_including(document_type: AaibReport.document_type))
    publishing_api_has_content([], document_type: 'manual', fields: manual_fields, per_page: 10000)
  end

  context "as a CMA Editor" do
    before do
      log_in_as_editor(:cma_editor)
    end

    scenario "visiting /cma-cases" do
      visit "/cma-cases"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("CMA Cases")
    end

    scenario "visiting /aaib-reports" do
      visit "/aaib-reports"

      expect(page.current_path).to eq("/manuals")
      expect(page).to have_content("You aren't permitted to access AAIB Reports")
    end

    scenario "visiting a format which doesn't exist" do
      visit "/a-format-which-doesnt-exist"

      expect(page.current_path).to eq("/manuals")
      expect(page).to have_content("That format doesn't exist.")
    end
  end

  context "as an AAIB Editor" do
    before do
      log_in_as_editor(:aaib_editor)
    end

    scenario "visiting /aaib-reports" do
      visit "/aaib-reports"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("AAIB Reports")
    end

    scenario "visiting /cma-cases" do
      visit "/cma-cases"

      expect(page.current_path).to eq("/manuals")
      expect(page).to have_content("You aren't permitted to access CMA Cases")
    end
  end

  context "viewing manuals" do
    let(:manual_content_item_1) { Payloads.manual_content_item("title" => "Example manual") }
    let(:manual_links_1) { Payloads.manual_links }

    let(:manual_content_id_2) { SecureRandom.uuid }
    let(:manual_content_item_2) { Payloads.manual_content_item("title" => "Exemplar manual", "content_id" => manual_content_id_2) }
    let(:manual_links_2) { Payloads.manual_links("content_id" => manual_content_id_2, "links" => { "organisations" => [organisation_user.organisation_content_id] }) }

    let(:organisation_user) { FactoryGirl.create(:cma_editor) }
    let(:manual_fields) { %i[content_id description title details public_updated_at publication_state base_path update_type] }
    before do
      publishing_api_has_item(manual_content_item_1)
      publishing_api_has_item(manual_content_item_2)

      publishing_api_has_content([manual_content_item_1, manual_content_item_2], document_type: 'manual', fields: manual_fields, per_page: 10000)

      [manual_links_1, manual_links_2].each do |link_set|
        publishing_api_has_links(link_set)
        link_set['links']['organisations'].each do |organisation|
          organisation = { content_id: organisation, base_path: "/government/organisations/#{organisation}", title: 'Government Digital Service' }
          publishing_api_has_item(organisation)
        end
      end
    end

    context 'as a GDS editor' do
      before do
        log_in_as_editor(:gds_editor)
      end

      scenario "visiting /manuals" do
        visit "/manuals"

        expect(page.status_code).to eq(200)
        expect(page).to have_content 'Example manual'
        expect(page).to have_content 'Exemplar manual'
      end
    end

    context 'as a organisation editor' do
      before do
        log_in_as(organisation_user)
      end

      scenario "visiting /manuals" do
        visit "/manuals"

        expect(page.status_code).to eq(200)
        expect(page).not_to have_content 'Example manual'
        expect(page).to have_content 'Exemplar manual'
      end
    end
  end
end
