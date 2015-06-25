When(/^I create a Medical Safety Alert$/) do
  @slug = "drug-device-alerts/example-medical-safety-alert"
  @document_fields = msa_fields
  @msa_metadata_values = msa_metadata_fields

  create_medical_safety_alert(@document_fields)
end

Then(/^the Medical Safety Alert has been created$/) do
  check_medical_safety_alert_exists_with(@document_fields)
end

When(/^I create a Medical Safety Alert with invalid fields$/) do
  @document_fields = {
    body: "<script>alert('Oh noes!)</script>",
  }
  create_medical_safety_alert(@document_fields)
end

Then(/^the Medical Safety Alert should not have been created$/) do
  check_document_does_not_exist_with(@document_fields)
end

Given(/^a draft Medical Safety Alert exists$/) do
  @slug = "drug-device-alerts/example-medical-safety-alert"
  @document_fields = msa_fields
  @msa_metadata_values = msa_metadata_fields

  create_medical_safety_alert(@document_fields)
end

When(/^I edit a Medical Safety Alert and remove required fields$/) do
  edit_medical_safety_alert(@document_fields.fetch(:title), summary: "")
end

Then(/^the Medical Safety Alert should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Given(/^two Medical Safety Alerts exist$/) do
  @document_fields = msa_fields
  @msa_metadata_values = msa_metadata_fields

  create_medical_safety_alert(@document_fields)

  @document_fields = msa_fields.merge({
    title: "Example Medical Safety Alert 2",
  })
  @msa_metadata_values = msa_metadata_fields

  create_medical_safety_alert(@document_fields)
end

Then(/^the Medical Safety Alerts should be in the publisher MSA index in the correct order$/) do
  visit medical_safety_alerts_path

  check_for_documents("Example Medical Safety Alert", "Example Medical Safety Alert 2")
end

When(/^I edit a Medical Safety Alert$/) do
  @new_title = "New Medical Safety Alert Title"
  edit_medical_safety_alert(@document_fields.fetch(:title), title: @new_title)
end

Then(/^the Medical Safety Alert should have been updated$/) do
  check_for_new_medical_safety_alert_title(@new_title)
end

Then(/^the Medical Safety Alert should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the Medical Safety Alert$/) do
  go_to_show_page_for_medical_safety_alert(@document_fields.fetch(:title))
  publish_document
end

Then(/^the Medical Safety Alert should be published$/) do
  check_document_is_published(@slug, @document_fields.merge(@msa_metadata_values))
end

When(/^I publish a new Medical Safety Alert$/) do
  @slug = "drug-device-alerts/example-medical-safety-alert"
  @document_fields = msa_fields
  @msa_metadata_values = msa_metadata_fields

  create_medical_safety_alert(@document_fields, publish: true)
end

Given(/^a published Medical Safety Alert exists$/) do
  @slug = "drug-device-alerts/example-medical-safety-alert"
  @document_fields = msa_fields
  @msa_metadata_values = msa_metadata_fields

  create_medical_safety_alert(@document_fields, publish: true)
end

When(/^I withdraw a Medical Safety Alert$/) do
  withdraw_medical_safety_alert(@document_fields.fetch(:title))
end

Then(/^the Medical Safety Alert should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @document_fields.fetch(:title))
end

When(/^I am on the Medical Safety Alert edit page$/) do
  go_to_edit_page_for_medical_safety_alert(@document_fields.fetch(:title))
end

def msa_fields
  {
    title: "Example Medical Safety Alert",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    alert_type: "Drug alert",
    issued_date: "2014-01-01",
  }
end

def msa_metadata_fields
  {
    alert_type: "drugs",
  }
end
