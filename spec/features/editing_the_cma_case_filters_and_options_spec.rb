require "spec_helper"
require "gds_api/test_helpers/support_api"

RSpec.feature "Editing the CMA case finder filters and options", type: :feature do
  include GdsApi::TestHelpers::SupportApi

  let(:organisations) do
    [
      { "content_id" => "957eb4ec-089b-4f71-ba2a-dc69ac8919ea", "title" => "Competition and Markets Authority" },
    ]
  end

  before do
    log_in_as_editor(:cma_editor)
    stub_publishing_api_has_content([], hash_including(document_type: CmaCase.document_type))
    stub_publishing_api_has_content(organisations, hash_including(document_type: Organisation.document_type))
    stub_any_support_api_call
  end

  scenario "editing a filter" do
    visit "admin/cma-cases"
    within "#facets_summary_card" do
      click_link "Request changes"
    end

    expect(page).to have_selector("span", text: "CMA Case finder")
    expect(page).to have_selector("h1", text: "Request change: Filters and options")

    # This first field is deliberately kept the same as the original value,
    # otherwise looks like a new filter on the summary page, which is just confusing
    fill_in "facets[0][name]", with: "Case type"
    # All of the other fields are just set to arbitrary values, to check that they even exist
    fill_in "facets[0][short_name]", with: "short name"
    select "One option", from: "facets[0][type]"
    fill_in "facets[0][allowed_values]", with: "foo\nbar"
    choose "facets[0][filterable]", option: "false"
    choose "facets[0][display_as_result_metadata]", option: "false"
    fill_in "facets[0][preposition]", with: "of type NEW"

    # Check that the summary page shows the changes
    click_button "Submit changes"
    expect(page).to have_selector(".govuk-summary-list__row", text: "Case type Updated (click on 'View diff' for details)")

    # Check that the Zendesk ticket was successfully created
    click_button "Submit changes"
    expect(page).to have_selector(".gem-c-success-alert__message", text: "Your changes have been submitted and Zendesk ticket created.")
  end

  # TODO: requires JavaScript (for the 'add another' functionality)
  # scenario "editing, deleting and adding new filters" do
  #   visit "admin/cma-cases"
  #   within "#facets_summary_card" do
  #     click_link "Request changes"
  #   end

  #   expect(page).to have_selector("span", text: "CMA Case finder")
  #   expect(page).to have_selector("h1", text: "Request change: Filters and options")

  #   # Delete all but the first filter
  #   while all(".js-add-another__remove-button").count > 1
  #     all(".js-add-another__remove-button").last.click
  #   end

  #   puts page.body

  #   # Edit one of the fields of the first filter
  #   fill_in "facets[0][name]", with: "Case type NEW"

  #   # Create a new filter, using all of the inputs
  #   click_button "Add another filter"
  #   fill_in "facets[1][name]", with: "New filter"
  #   fill_in "facets[1][short_name]", with: "short name"
  #   select "One option", from: "facets[1][type]"
  #   fill_in "facets[1][allowed_values]", with: "foo\nbar"
  #   choose "facets[1][filterable]", option: "false"
  #   choose "facets[1][display_as_result_metadata]", option: "false"
  #   fill_in "facets[1][preposition]", with: "of type NEW"

  #   click_button "Submit changes"

  #   puts page.body
  #   # TODO: add some more assertions
  #   expect(page).to have_selector(".govuk-summary-list__row", text: "Case type Updated (click on 'View diff' for details)")

  #   # click_button "Submit changes"
  #   # expect(page).to have_selector(".gem-c-success-alert__message", text: "Your changes have been submitted and Zendesk ticket created.")
  # end
end
