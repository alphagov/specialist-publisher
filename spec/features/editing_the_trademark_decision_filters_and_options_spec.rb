require "spec_helper"
require "gds_api/test_helpers/support_api"

RSpec.feature "Editing the Trademark Decisions finder filters and options", type: :feature do
  include GdsApi::TestHelpers::SupportApi

  let(:organisations) do
    [
      { "content_id" => "5d6f9583-991f-413d-ae83-be7274e5eae4", "title" => "Intellectual Property Office (IPO)" },
    ]
  end

  before do
    Capybara.current_driver = Capybara.javascript_driver
    log_in_as_editor(:gds_editor)
    stub_publishing_api_has_content([], hash_including(document_type: TrademarkDecision.document_type))
    stub_publishing_api_has_content(organisations, hash_including(document_type: Organisation.document_type))
    stub_any_support_api_call
  end

  scenario "editing, deleting and adding new filters" do
    visit "finders/trademark-decisions"
    within "#facets_summary_card" do
      click_link "Request changes"
    end

    expect(page).to have_selector("span", text: "Trademark Decision finder")
    expect(page).to have_selector("h1", text: "Request change: Filters and options")

    # Delete all but the first filter
    all(".js-add-another__remove-button").last.click while all(".js-add-another__remove-button").count > 1

    click_button "Add another filter"
    within find("fieldset", text: "Filter 2") do
      inserted_facet = "facets[8]"
      fill_in "#{inserted_facet}[name]", with: "New filter"
      fill_in "#{inserted_facet}[short_name]", with: "short name"
      select "Nested - Multiple select", from: "#{inserted_facet}[type]"
      check "Required", visible: false
      fill_in "#{inserted_facet}[sub_facet]", with: "Sub Facet Name"
      fill_in "#{inserted_facet}[allowed_values]", with: "Main Facet 1{main-facet-1}\nSub Facet 11{sub-facet-11}\nSub Facet 12 NEW\r\n\r\nMain Facet 2{main-facet-2}\nSub Facet 21{sub-facet-21}\nSub Facet 22{sub-facet-22}\r\n\r\nMain Facet 3{main-facet-3}"
      choose "#{inserted_facet}[filterable]", option: "true", visible: false
      choose "#{inserted_facet}[display_as_result_metadata]", option: "false", visible: false
      fill_in "#{inserted_facet}[preposition]", with: "of type NEW"
      choose "#{inserted_facet}[show_option_select_filter]", option: "true", visible: false
    end

    click_button "Submit changes"

    expect(page).to have_selector(".govuk-summary-list__row", text: "New filter Added (click on 'View diff' for details)")
    expect(page).to have_selector(".govuk-summary-list__row", text: "Type of hearing Deleted")
    expect(page).to have_selector(".govuk-summary-list__row", text: "Mark Deleted")
    expect(page).to have_selector(".govuk-summary-list__row", text: "Class Deleted")
    expect(page).to have_selector(".govuk-summary-list__row", text: "Decision date Deleted")
    expect(page).to have_selector(".govuk-summary-list__row", text: "Appointed person/hearing officer Deleted")
    expect(page).to have_selector(".govuk-summary-list__row", text: "Person or company involved Deleted")
    expect(page).to have_selector(".govuk-summary-list__row", text: "Grounds Section Deleted")
    expect(page).to have_selector("details summary", text: "View diff")
    expect(page).to have_selector("details summary", text: "View generated schema")

    click_button "Submit changes"
    expect(page).to have_selector(".gem-c-success-alert__message", text: "Your changes have been submitted and Zendesk ticket created.")
  end

  scenario "the generated schema is outputted to a hidden input ready for form submission" do
    visit "admin/facets/trademark-decisions"
    click_button "Submit changes"
    hidden_input = find("[name=proposed_schema]", visible: false)
    expect(hidden_input.value).to eq(JSON.pretty_generate(JSON.parse(TrademarkDecision.finder_schema.to_json)))
  end
end
