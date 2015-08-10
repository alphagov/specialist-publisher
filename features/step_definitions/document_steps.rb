Then(/^an email alert should not be sent$/) do
  expect(fake_email_alert_api).to_not have_received(:send_alert)
end

When(/^I edit the document without a change note$/) do
  @updated_document_fields = {
    body: "Updated section",
    change_note: "",
  }

  @document_fields = @document_fields.merge(@updated_document_fields)

  edit_document(@document_title, @updated_document_fields)
end

When(/^I edit the document with a change note$/) do
  @updated_document_fields = {
    body: "Updated section",
    change_note: "This is a Major Lazer change",
  }

  @document_fields = @document_fields.merge(@updated_document_fields)

  edit_document(@title, @updated_document_fields)
end

When(/^I edit the document and indicate the change is minor$/) do
  @updated_document_fields = {
    body: "Updated section",
  }

  @document_fields = @document_fields.merge(@updated_document_fields)

  edit_document(@title, @updated_document_fields, minor_update: true)
end

When(/^I edit the document and republish$/) do
  @amended_document_attributes = {summary: "New summary", title: "My title"}
  edit_document(@document_fields.fetch(:title), @amended_document_attributes, minor_update: true, publish: true)
end

Then(/^the publish should(?: still)* have been logged (\d+) times?$/) do |expected_count_of_logs|
  check_count_of_logs(expected_count_of_logs)
end

Then(/^the document should be sent to content preview/) do
  check_document_published_to_publishing_api(@slug, @document_fields, draft: true)
end

Then(/^I should see a link to preview the document$/) do
  check_content_preview_link(@slug)
end

Then(/^I should see a link to the live document$/) do
  check_live_link(@slug)
end
