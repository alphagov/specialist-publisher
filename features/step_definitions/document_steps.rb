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
