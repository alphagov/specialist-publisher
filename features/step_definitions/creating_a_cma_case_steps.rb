Given(/^I am logged in as a CMA editor$/) do
  login_as(:cma_editor)
end

When(/^I create a CMA case$/) do
  @cma_fields = {
    title: 'Example CMA Case',
    summary: 'Nullam quis risus eget urna mollis ornare vel eu leo.',
    body: ('Praesent commodo cursus magna, vel scelerisque nisl consectetur et.' * 10)
  }

  create_cma_case(@cma_fields)
end

When(/^I create a CMA case without one of the required fields$/) do
  @cma_fields = {
    summary: 'Nullam quis risus eget urna mollis ornare vel eu leo.',
    body: ('Praesent commodo cursus magna, vel scelerisque nisl consectetur et.' * 10)
  }

  create_cma_case(@cma_fields)
end

def create_cma_case(fields)
  stub_out_panopticon

  visit new_specialist_document_path
  fill_in_cma_fields(fields)

  save_document
end

Given(/^two CMA cases exist$/) do
  stub_out_panopticon

  2.times do |index|
    doc = SpecialistDocument.new(title: "Specialist Document #{index+1}")
    SpecialistDocumentRegistry.store!(doc)

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
