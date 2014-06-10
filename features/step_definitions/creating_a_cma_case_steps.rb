Given(/^I am logged in as a CMA editor$/) do
  login_as(:cma_editor)

  # WARNING: These must be stubbed before the first request takes place
  stub_out_panopticon
  stub_finder_api
end

When(/^I create a CMA case$/) do
  @document_title = "Example CMA Case"
  @slug = "cma-cases/example-cma-case"
  @cma_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    opened_date: "2014-01-01"
  }

  create_cma_case(@cma_fields)
end

When(/^I create a CMA case without one of the required fields$/) do
  @cma_fields = {
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    opened_date: "2014-01-01"
  }

  create_cma_case(@cma_fields)
end

When(/^I publish a new CMA case$/) do
  @document_title = "Example CMA Case"
  @slug = "cma-cases/example-cma-case"

  @cma_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    opened_date: "2014-01-01"
  }

  create_cma_case(@cma_fields, publish: true)
end

When(/^I edit a CMA case$/) do
  @new_title = "Edited Example CMA Case"
  edit_cma_case(@document_title, title: @new_title)
end

Then(/^the CMA case should have been updated$/) do
  check_for_new_title
end

Given(/^two CMA cases exist$/) do
  seed_cases(2)
end

Given(/^a draft CMA case exists$/) do
  @document_title = "Example CMA Case"
  @slug = "cma-cases/example-cma-case"

  @cma_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    opened_date: "2014-01-01"
  }

  create_cma_case(@cma_fields, publish: false)
end

Then(/^the CMA case has been created$/) do
  check_cma_case_exists_with(@cma_fields)
  check_slug_registered_with_panopticon(@slug)
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

Given(/^a published CMA case exists$/) do
  @document_title = "Original CMA case title"

  @cma_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: ("Praesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    opened_date: "2014-01-01",
  }

  @slug = "cma-cases/original-cma-case-title"

  create_cma_case(@cma_fields, publish: true)
end

When(/^I change the CMA case title and re-publish$/) do
  @updated_title = "Updated CMA case title"
  update_title_and_republish(@document_title, to: @updated_title)
end

Then(/^the title has been updated$/) do
  check_for_cma_cases(@updated_title)
end

Then(/^the URL slug remains unchanged$/) do
  check_for_unchanged_slug(@updated_title, @slug)
end

When(/^I create another case with the same slug$/) do
  create_cma_case(@cma_fields)
end

Then(/^I should see an error message about the duplicate slug$/) do
  check_for_error("Slug is already taken")
end

When(/^I start creating a new CMA case$/) do
  @document_title = "Original CMA case title"

  @cma_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "Body for preview",
    opened_date: "2014-01-01",
  }

  create_cma_case(@cma_fields, save: false)
end

When(/^I preview the case$/) do
  generate_preview
end
