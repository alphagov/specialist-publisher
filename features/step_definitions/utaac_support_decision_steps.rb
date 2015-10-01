When(/^I create a UTAAC decision$/) do
  @document_title = "Example UTAAC decision"
  @slug = "utaac-decisions/example-utaac-decision"
  @document_fields = utaac_decision_fields(title: @document_title)

  create_utaac_decision(@document_fields)
end

Then(/^the UTAAC decision has been created$/) do
  fields = @document_fields
  fields["Hidden indexable content"] = "## Header Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Praesent commodo cursus magna, vel scelerisque nisl c..."

  check_utaac_decision_exists_with(fields)
end

When(/^I create a UTAAC decision with invalid fields$/) do
  @document_fields = utaac_decision_fields(
    title: "",
    summary: "",
    body: "<script>alert('Oh noes!)</script>",
    "Decision date" => "Bad data",
  )

  create_utaac_decision(@document_fields)
end

Then(/^the UTAAC decision should not have been created$/) do
  check_document_does_not_exist_with(@document_fields)
end

Given(/^two UTAAC decisions exist$/) do
  @document_fields = utaac_decision_fields(title: "UTAAC decision 1")
  create_utaac_decision(@document_fields)

  @document_fields = utaac_decision_fields(title: "UTAAC decision 2")
  create_utaac_decision(@document_fields)
end

Then(/^the UTAAC decisions should be in the publisher report index in the correct order$/) do
  visit utaac_decisions_path

  check_for_documents("UTAAC decision 2", "UTAAC decision 1")
end

Given(/^a draft UTAAC decision exists$/) do
  @document_title = "Example UTAAC decision"
  @slug = "utaac-decisions/example-utaac-decision"
  @document_fields = utaac_decision_fields(title: @document_title)
  @rummager_fields = utaac_decision_rummager_fields(title: @document_title)

  create_utaac_decision(@document_fields)
end

When(/^I edit a UTAAC decision$/) do
  @new_title = "Edited Example UTAAC decision"
  edit_utaac_decision(@document_title, title: @new_title)
end

When(/^I edit an UTAAC decision and remove required fields$/) do
  edit_utaac_decision(@document_title, summary: "")
end

Then(/^the UTAAC decision should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Then(/^the UTAAC decision should have been updated$/) do
  check_for_new_utaac_decision_title(@new_title)
end

Given(/^there is a published UTAAC decision with an attachment$/) do
  @document_title = "Example UTAAC decision"
  @attachment_title = "My attachment"

  @slug = "utaac-decisions/example-utaac-decision"
  @document_fields = utaac_decision_fields(title: @document_title)

  create_utaac_decision(@document_fields, publish: true)
  add_attachment_to_document(@document_title, @attachment_title)
end

Given(/^a published UTAAC decision exists$/) do
  @document_title = "Example UTAAC decision"
  @slug = "utaac-decisions/example-utaac-decision"
  @document_fields = utaac_decision_fields(title: @document_title)

  create_utaac_decision(@document_fields, publish: true)
end

When(/^I withdraw an UTAAC decision$/) do
  withdraw_utaac_decision(@document_fields.fetch(:title))
end

Then(/^the UTAAC decision should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @document_fields.fetch(:title))
end

When(/^I am on the UTAAC decision edit page$/) do
  go_to_edit_page_for_utaac_decision(@document_fields.fetch(:title))
end

Then(/^the UTAAC decision should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the UTAAC decision$/) do
  go_to_show_page_for_utaac_decision(@document_title)
  publish_document
end

Then(/^the UTAAC decision should be published$/) do
  check_document_is_published(@slug, @rummager_fields)
end

When(/^I publish a new UTAAC decision$/) do
  @document_title = "Example UTAAC decision"
  @slug = "utaac-decisions/example-utaac-decision"
  @document_fields = utaac_decision_fields(title: @document_title)
  @rummager_fields = utaac_decision_rummager_fields(title: @document_title)

  create_utaac_decision(@document_fields, publish: true)
end
