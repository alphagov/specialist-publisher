Given(/^I am logged in as a CMA editor$/) do
  login_as(:cma_editor)
end

When(/^I create a CMA case$/) do
  @cma_fields = {
    title: 'Example CMA Case',
    summary: 'Nullam quis risus eget urna mollis ornare vel eu leo.',
    body: ('Praesent commodo cursus magna, vel scelerisque nisl consectetur et.' * 10),
    opened_date: '2014-01-01'
  }

  create_cma_case(@cma_fields)
end

When(/^I create a CMA case without one of the required fields$/) do
  @cma_fields = {
    summary: 'Nullam quis risus eget urna mollis ornare vel eu leo.',
    body: ('Praesent commodo cursus magna, vel scelerisque nisl consectetur et.' * 10),
    opened_date: '2014-01-01'
  }

  create_cma_case(@cma_fields)
end

When(/^I publish a new CMA case$/) do
  @cma_fields = {
    title: 'Example CMA Case',
    summary: 'Nullam quis risus eget urna mollis ornare vel eu leo.',
    body: ('Praesent commodo cursus magna, vel scelerisque nisl consectetur et.' * 10),
    opened_date: '2014-01-01'
  }

  create_cma_case(@cma_fields, publish: true)
end

When(/^I edit a CMA case$/) do
  @new_title = 'Edited Example CMA Case'
  edit_cma_case(title: @new_title)
end

Then(/^the CMA case should have been updated$/) do
  check_for_new_title
end

Given(/^two CMA cases exist$/) do
  create_cases(2)
end

Given(/^a draft CMA case exists$/) do
  create_cases(1)
end

def create_cases(number_of_cases, state: 'draft')
  stub_out_panopticon
  number_of_cases.times do |index|

    doc = specialist_document_builder.call(
      title: "Specialist Document #{index+1}",
      summary: "summary",
      body: "body",
      opened_date: Time.zone.parse("2014-01-01"),
      market_sector: 'agriculture-environment-and-natural-resources',
      case_state: 'open',
      case_type: 'ca98',
      state: state,
    )

    specialist_document_repository.store!(doc)

    Timecop.travel(10.minutes.from_now)
  end
end

Then(/^the CMA case should exist$/) do
  check_cma_case_exists_with(@cma_fields)
end

Then(/^I should see an error message about a missing field$/) do
  check_for_missing_title_error
end

Then(/^the CMA case should not have been created$/) do
  check_cma_case_does_not_exist_with(@cma_fields)
end

Then(/^the CMA cases should be in the publisher case index in the correct order$/) do
  visit specialist_documents_path

  check_for_cma_cases("Specialist Document 2", "Specialist Document 1")
end

Then(/^I should be returned to the list of documents$/) do
  check_currently_on_publisher_index_page
end

When(/^I make changes and preview the CMA case$/) do
  make_changes_without_saving(
    title: "Title for preview",
    body: "Body for preview",
  )
  generate_preview
end

Then(/^I see the case body preview$/) do
  check_for_cma_case_body_preview
end
