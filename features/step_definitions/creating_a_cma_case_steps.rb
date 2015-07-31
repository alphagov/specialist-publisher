When(/^I create a CMA case$/) do
  @document_title = "Example CMA Case"
  @slug = "cma-cases/example-cma-case"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    opened_date: "2014-01-01",
    market_sector: "Energy",
  }

  create_cma_case(@document_fields)
end

When(/^I create a CMA case with invalid fields$/) do
  @document_fields = {
    body: "<script>alert('Oh noes!)</script>",
    opened_date: "Bad data"
  }

  create_cma_case(@document_fields)
end

When(/^I publish a new CMA case$/) do
  @document_title = "Example CMA Case"
  @slug = "cma-cases/example-cma-case"

  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    opened_date: "2014-01-01",
    market_sector: "Energy",
  }

  create_cma_case(@document_fields, publish: true)
end

When(/^I edit a CMA case$/) do
  @new_title = "Edited Example CMA Case"
  edit_cma_case(@document_title, title: @new_title)
end

Then(/^the CMA case should have been updated$/) do
  check_for_new_cma_case_title(@new_title)
end

Given(/^two CMA cases exist$/) do
  @documents = seed_cases(2)
end

Given(/^a draft CMA case exists$/) do
  @document_title = "Example CMA Case"
  @slug = "cma-cases/example-cma-case"

  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    opened_date: "2014-01-01",
    market_sector: "Energy",
  }

  create_cma_case(@document_fields, publish: false)
end

Then(/^the CMA case has been created$/) do
  check_cma_case_exists_with(@document_fields)
end

Then(/^the CMA case should not have been created$/) do
  check_document_does_not_exist_with(@document_fields)
end

Then(/^the CMA cases should be in the publisher case index in the correct order$/) do
  visit cma_cases_path

  check_for_documents(*@documents.map(&:title))
end

When(/^I make changes and preview the CMA case$/) do
  change_cma_case_without_saving(
    @document_title,
    title: "Title for preview",
    body: "Body for preview",
  )
  generate_preview
end

Then(/^I see the case body preview$/) do
  check_for_cma_case_body_preview
end

Given(/^a published CMA case exists$/) do
  @document_title = "Original CMA case title"

  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    opened_date: "2014-01-01",
    market_sector: "Energy",
  }

  @slug = "cma-cases/original-cma-case-title"

  create_cma_case(@document_fields, publish: true)
end

When(/^I change the CMA case title and re-publish$/) do
  @updated_title = "Updated CMA case title"
  update_title_and_republish_cma_case(@document_title, to: @updated_title)
end

Then(/^the title has been updated$/) do
  check_for_documents(@updated_title)
end

Then(/^the URL slug remains unchanged$/) do
  check_for_unchanged_slug(@updated_title, @slug)
end

When(/^I create another case with the same slug$/) do
  create_cma_case(@document_fields)
end

When(/^I start creating a new CMA case$/) do
  @document_title = "Original CMA case title"

  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "Body for preview",
    opened_date: "2014-01-01",
    market_sector: "Energy",
  }

  create_cma_case(@document_fields, save: false)
end

When(/^I start creating a new CMA case with embedded javascript$/) do
  @document_fields = {
    body: "<script>alert('Oh noes!)</script>",
  }

  create_cma_case(@document_fields, save: false)
end

When(/^I preview the case$/) do
  generate_preview
end

Then(/^I should not see an error$/) do
  check_publication_has_not_raised_error
end

When(/^I am on the CMA case edit page$/) do
  go_to_edit_page_for_cma_case(@document_title)
end
