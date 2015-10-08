When(/^I create a tax tribunal decision$/) do
  @document_title = "Example tax tribunal decision"
  @slug = "tax-and-chancery-tribunal-decisions/example-tax-tribunal-decision"
  @document_fields = tax_tribunal_decision_fields(title: @document_title)

  create_tax_tribunal_decision(@document_fields)
end

Then(/^the tax tribunal decision has been created$/) do
  fields = @document_fields
  fields["Hidden indexable content"] = "## Header Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Praesent commodo cursus magna, vel scelerisque nisl c..."

  check_tax_tribunal_decision_exists_with(fields)
end

When(/^I create a tax tribunal decision with invalid fields$/) do
  @document_fields = tax_tribunal_decision_fields(
    title: "",
    summary: "",
    body: "<script>alert('Oh noes!)</script>",
    "Release date" => "Bad data",
  )

  create_tax_tribunal_decision(@document_fields)
end

Then(/^the tax tribunal decision should not have been created$/) do
  check_document_does_not_exist_with(@document_fields)
end

Given(/^two tax tribunal decisions exist$/) do
  @document_fields = tax_tribunal_decision_fields(title: "tax tribunal decision 1")
  create_tax_tribunal_decision(@document_fields)

  @document_fields = tax_tribunal_decision_fields(title: "tax tribunal decision 2")
  create_tax_tribunal_decision(@document_fields)
end

Then(/^the tax tribunal decisions should be in the publisher report index in the correct order$/) do
  visit tax_tribunal_decisions_path

  check_for_documents("tax tribunal decision 2", "tax tribunal decision 1")
end

Given(/^a draft tax tribunal decision exists$/) do
  @document_title = "Example tax tribunal decision"
  @slug = "tax-and-chancery-tribunal-decisions/example-tax-tribunal-decision"
  @document_fields = tax_tribunal_decision_fields(title: @document_title)
  @rummager_fields = tax_tribunal_decision_rummager_fields(title: @document_title)

  create_tax_tribunal_decision(@document_fields)
end

When(/^I edit a tax tribunal decision$/) do
  @new_title = "Edited Example tax tribunal decision"
  edit_tax_tribunal_decision(@document_title, title: @new_title)
end

When(/^I edit a tax tribunal decision and remove required fields$/) do
  edit_tax_tribunal_decision(@document_title, summary: "")
end

Then(/^the tax tribunal decision should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Then(/^the tax tribunal decision should have been updated$/) do
  check_for_new_tax_tribunal_decision_title(@new_title)
end

Given(/^there is a published tax tribunal decision with an attachment$/) do
  @document_title = "Example tax tribunal decision"
  @attachment_title = "My attachment"

  @slug = "tax-and-chancery-tribunal-decisions/example-tax-tribunal-decision"
  @document_fields = tax_tribunal_decision_fields(title: @document_title)

  create_tax_tribunal_decision(@document_fields, publish: true)
  add_attachment_to_document(@document_title, @attachment_title)
end

Given(/^a published tax tribunal decision exists$/) do
  @document_title = "Example tax tribunal decision"
  @slug = "tax-and-chancery-tribunal-decisions/example-tax-tribunal-decision"
  @document_fields = tax_tribunal_decision_fields(title: @document_title)

  create_tax_tribunal_decision(@document_fields, publish: true)
end

When(/^I withdraw a tax tribunal decision$/) do
  withdraw_tax_tribunal_decision(@document_fields.fetch(:title))
end

Then(/^the tax tribunal decision should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @document_fields.fetch(:title))
end

When(/^I am on the tax tribunal decision edit page$/) do
  go_to_edit_page_for_tax_tribunal_decision(@document_fields.fetch(:title))
end

Then(/^the tax tribunal decision should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the tax tribunal decision$/) do
  go_to_show_page_for_tax_tribunal_decision(@document_title)
  publish_document
end

Then(/^the tax tribunal decision should be published$/) do
  check_document_is_published(@slug, @rummager_fields)
end

When(/^I publish a new tax tribunal decision$/) do
  @document_title = "Example tax tribunal decision"
  @slug = "tax-and-chancery-tribunal-decisions/example-tax-tribunal-decision"
  @document_fields = tax_tribunal_decision_fields(title: @document_title)
  @rummager_fields = tax_tribunal_decision_rummager_fields(title: @document_title)

  create_tax_tribunal_decision(@document_fields, publish: true)
end
