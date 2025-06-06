require "spec_helper"

RSpec.feature "Creating a Flood and Coastal Erosion Risk Management Research Report ", type: :feature do
  let(:document) { FactoryBot.create(:flood_and_coastal_erosion_risk_management_research_report) }
  let(:content_id) { document["content_id"] }
  let(:document_type) { :flood_and_coastal_erosion_risk_management_research_report }
  let(:document_model) { document_type.to_s.camelize.constantize }
  let(:base_path) { "/#{document_model.admin_slug}" }
  let(:new_document_path) { "#{base_path}/new" }
  let(:schema) { document_model.finder_schema }
  let(:organisation_content_id_for_authorized_user) { "ad8e70ad-eb0c-45fd-9a8b-3a52409fae85" }
  let(:organisation_name_for_authorized_user) { "Department for Science, Innovation and Technology" }
  let(:organisations) do
    [
      { "content_id" => organisation_content_id_for_authorized_user, "title" => organisation_name_for_authorized_user },
      { "content_id" => "aaaaaaaa-eb0c-45fd-9a8b-3a52409fae85", "title" => "Not the Department for Science, Innovation and Technology" },
    ]
  end

  before do
    log_in_as_design_system_editor(:gds_editor, organisation_content_id_for_authorized_user)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
    stub_publishing_api_has_content(organisations, hash_including(document_type: Organisation.document_type))
    stub_publishing_api_has_content([document], hash_including(document_type: document_type.to_s))
    stub_publishing_api_has_item(document)
  end

  scenario "creating a new document" do
    visit base_path
    click_link "Add another #{schema.document_title}"
    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq(new_document_path)
  end

  scenario "saving a new document with no data" do
    visit new_document_path
    fill_in "Body", with: ""
    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_css(".govuk-error-message", text: "Title can't be blank")
    expect(page).to have_css(".govuk-error-message", text: "Summary can't be blank")
    expect(page).to have_css(".govuk-error-message", text: "Body can't be blank")

    schema.facets.each do |facet|
      properties = facet["specialist_publisher_properties"] || {}
      validations = properties["validations"] || {}

      next unless validations["required"]

      error_regex = /#{facet['key'].humanize} can't be blank|#{facet['name']} can't be blank/
      expect(page).to have_css(".gem-c-error-summary__list-item", text: error_regex)
      expect(page).to have_css(".govuk-error-message", text: error_regex)
    end
  end

  scenario "saving a new document with valid data" do
    visit new_document_path

    fill_in "Title", with: "Example #{document_type.to_s.humanize}"
    fill_in "Summary", with: "Example Summary"
    fill_in "Body", with: "Example Body"

    schema.facets.each do |facet|
      key = facet["key"]
      properties = facet["specialist_publisher_properties"] || {}

      if facet["type"] == "date"
        fill_in "#{document_type}[#{key}(1i)]", with: "2014"
        fill_in "#{document_type}[#{key}(2i)]", with: "01"
        fill_in "#{document_type}[#{key}(3i)]", with: "01"
      elsif properties["select"] == "one"
        select facet["allowed_values"].first["label"], from: facet["name"], match: :first
      elsif properties["select"] == "multiple"
        select facet["allowed_values"].first["label"], from: "#{document_type}[#{facet['key']}][]"
      else
        fill_in facet["name"], with: "Example #{facet['name']}"
      end
    end
    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")

    # Expect page to have preselected organisation if it's registered on the model
    expect(page).to have_content(organisation_name_for_authorized_user) if document["links"]["primary_publishing_organisation"]
    # Select value for custom 'organisations' field
    select organisation_name_for_authorized_user, from: "#{document_type}[organisations][]"

    click_button "Save as draft"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example #{document_type.to_s.humanize}")
  end
end
