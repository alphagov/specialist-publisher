Given(/^I am logged in as a CMA editor$/) do
  login_as(:cma_editor)
end

When(/^I create a CMA case$/) do
  stub_out_panopticon

  visit new_specialist_document_path

  @cma_fields = {
    title: 'Example CMA Case',
    summary: 'Nullam quis risus eget urna mollis ornare vel eu leo.',
    body: ('Praesent commodo cursus magna, vel scelerisque nisl consectetur et.' * 10)
  }
  fill_in_cma_fields(@cma_fields)

  save_document
end

Then(/^the CMA case should exist$/) do
  check_cma_case_exists_with(@cma_fields)
end
