When(/^I create a Drug Safety Update$/) do
  @slug = "drug-safety-update/example-drug-safety-update"
  @document_fields = {
    title: "Example Drug Safety Update",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    therapeutic_area: "Anaesthesia and intensive care",
  }
  @dsu_metadata_values = {
    therapeutic_area: ["anaesthesia-intensive-care"],
  }

  create_drug_safety_update(@document_fields)
end

Then(/^the Drug Safety Update has been created$/) do
  check_drug_safety_update_exists_with(@document_fields)
end

When(/^I create a Drug Safety Update with invalid fields$/) do
  @document_fields = {
    body: "<script>alert('Oh noes!)</script>",
  }
  create_drug_safety_update(@document_fields)
end

Then(/^the Drug Safety Update should not have been created$/) do
  check_document_does_not_exist_with(@document_fields)
end

Given(/^a draft Drug Safety Update exists$/) do
  @slug = "drug-safety-update/example-drug-safety-update"
  @document_fields = {
    title: "Example Drug Safety Update",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    therapeutic_area: "Anaesthesia and intensive care",
  }
  @dsu_metadata_values = {
    therapeutic_area: ["anaesthesia-intensive-care"],
  }

  create_drug_safety_update(@document_fields)
end

When(/^I edit a Drug Safety Update and remove required fields$/) do
  edit_drug_safety_update(@document_fields.fetch(:title), summary: "")
end

Then(/^the Drug Safety Update should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Given(/^two Drug Safety Updates exist$/) do
  @document_fields = {
    title: "Example Drug Safety Update 1",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    therapeutic_area: "Anaesthesia and intensive care",
  }
  @dsu_metadata_values = {
    therapeutic_area: ["anaesthesia-intensive-care"],
  }

  create_drug_safety_update(@document_fields)

  @document_fields = {
    title: "Example Drug Safety Update 2",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    therapeutic_area: "Anaesthesia and intensive care",
  }
  @dsu_metadata_values = {
    therapeutic_area: ["anaesthesia-intensive-care"],
  }
  create_drug_safety_update(@document_fields)
end

Then(/^the Drug Safety Updates should be in the publisher DSU index in the correct order$/) do
  visit drug_safety_updates_path

  check_for_documents("Example Drug Safety Update 1", "Example Drug Safety Update 2")
end

When(/^I edit a Drug Safety Update$/) do
  @new_title = "New Drug Safety Update Title"
  edit_drug_safety_update(@document_fields.fetch(:title), title: @new_title)
end

Then(/^the Drug Safety Update should have been updated$/) do
  check_for_new_drug_safety_update_title(@new_title)
end

Then(/^the Drug Safety Update should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the Drug Safety Update$/) do
  go_to_show_page_for_drug_safety_update(@document_fields.fetch(:title))
  publish_document
end

Then(/^the Drug Safety Update should be published$/) do
  check_document_is_published(
    @slug,
    @document_fields
      .merge(@dsu_metadata_values)
      .merge(first_published_at: "01-01-2001 01:00:00")
  )
end

When(/^I publish a new Drug Safety Update$/) do
  @slug = "drug-safety-update/example-drug-safety-update"
  @document_fields = {
    title: "Example Drug Safety Update",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    therapeutic_area: "Anaesthesia and intensive care",
  }
  @dsu_metadata_values = {
    therapeutic_area: ["anaesthesia-intensive-care"],
  }
  create_drug_safety_update(@document_fields, publish: true)
end

Given(/^a published Drug Safety Update exists$/) do
  @slug = "drug-safety-update/example-drug-safety-update"
  @document_fields = {
    title: "Example Drug Safety Update",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    therapeutic_area: "Anaesthesia and intensive care",
  }
  @dsu_metadata_values = {
    therapeutic_area: ["anaesthesia-intensive-care"],
  }
  create_drug_safety_update(@document_fields, publish: true)
end

When(/^I withdraw a Drug Safety Update$/) do
  withdraw_drug_safety_update(@document_fields.fetch(:title))
end

Then(/^the Drug Safety Update should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @document_fields.fetch(:title))
end

When(/^I am on the Drug Safety Update edit page$/) do
  go_to_edit_page_for_drug_safety_update(@document_fields.fetch(:title))
end
