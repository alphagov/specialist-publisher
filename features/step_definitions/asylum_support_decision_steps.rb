When(/^I create a asylum support decision$/) do
  @document_title = "Example asylum support decision"
  @slug = "asylum-support-tribunal-decisions/example-asylum-support-decision"
  @document_fields = asylum_support_decision_fields(title: @document_title)

  create_asylum_support_decision(@document_fields)
end

Then(/^the asylum support decision has been created$/) do
  fields = @document_fields
  fields["Hidden indexable content"] = "## Header Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Praesent commodo cursus magna, vel scelerisque nisl c..."

  check_asylum_support_decision_exists_with(fields)
end

When(/^I create a asylum support decision with invalid fields$/) do
  @document_fields = asylum_support_decision_fields(
    title: "",
    summary: "",
    body: "<script>alert('Oh noes!)</script>",
    "Decision date" => "Bad data",
  )

  create_asylum_support_decision(@document_fields)
end

Then(/^the asylum support decision should not have been created$/) do
  check_document_does_not_exist_with(@document_fields)
end

Given(/^two asylum support decisions exist$/) do
  @document_fields = asylum_support_decision_fields(title: "asylum support decision 1")
  create_asylum_support_decision(@document_fields)

  @document_fields = asylum_support_decision_fields(title: "asylum support decision 2")
  create_asylum_support_decision(@document_fields)
end

Then(/^the asylum support decisions should be in the publisher report index in the correct order$/) do
  visit asylum_support_decisions_path

  check_for_documents("asylum support decision 2", "asylum support decision 1")
end

Given(/^a draft asylum support decision exists$/) do
  @document_title = "Example asylum support decision"
  @slug = "asylum-support-tribunal-decisions/example-asylum-support-decision"
  @document_fields = asylum_support_decision_fields(title: @document_title)
  @rummager_fields = asylum_support_decision_rummager_fields(title: @document_title)

  create_asylum_support_decision(@document_fields)
end

When(/^I edit a asylum support decision$/) do
  @new_title = "Edited Example asylum support decision"
  edit_asylum_support_decision(@document_title, title: @new_title)
end

When(/^I edit an asylum support decision and remove required fields$/) do
  edit_asylum_support_decision(@document_title, summary: "")
end

Then(/^the asylum support decision should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Then(/^the asylum support decision should have been updated$/) do
  check_for_new_asylum_support_decision_title(@new_title)
end

Given(/^there is a published asylum support decision with an attachment$/) do
  @document_title = "Example asylum support decision"
  @attachment_title = "My attachment"

  @slug = "asylum-support-tribunal-decisions/example-asylum-support-decision"
  @document_fields = asylum_support_decision_fields(title: @document_title)

  create_asylum_support_decision(@document_fields, publish: true)
  add_attachment_to_document(@document_title, @attachment_title)
end

Given(/^a published asylum support decision exists$/) do
  @document_title = "Example asylum support decision"
  @slug = "asylum-support-tribunal-decisions/example-asylum-support-decision"
  @document_fields = asylum_support_decision_fields(title: @document_title)

  create_asylum_support_decision(@document_fields, publish: true)
end

When(/^I withdraw an asylum support decision$/) do
  withdraw_asylum_support_decision(@document_fields.fetch(:title))
end

Then(/^the asylum support decision should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @document_fields.fetch(:title))
end

When(/^I am on the asylum support decision edit page$/) do
  go_to_edit_page_for_asylum_support_decision(@document_fields.fetch(:title))
end

Then(/^the asylum support decision should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the asylum support decision$/) do
  go_to_show_page_for_asylum_support_decision(@document_title)
  publish_document
end

Then(/^the asylum support decision should be published$/) do
  check_document_is_published(@slug, @rummager_fields)
end

When(/^I publish a new asylum support decision$/) do
  @document_title = "Example asylum support decision"
  @slug = "asylum-support-tribunal-decisions/example-asylum-support-decision"
  @document_fields = asylum_support_decision_fields(title: @document_title)
  @rummager_fields = asylum_support_decision_rummager_fields(title: @document_title)

  create_asylum_support_decision(@document_fields, publish: true)
end
