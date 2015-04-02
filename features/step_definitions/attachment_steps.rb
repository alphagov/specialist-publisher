Given(/^there is an existing draft case$/) do
  @document_title = "Nullam quis risus"

  create_cma_case(
    title: @document_title,
    summary: "Eget urna mollis ornare vel eu leo.",
    body: ("Praesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    opened_date: "2014-01-01",
    market_sector: "Energy",
  )
end

When(/^I attach a file and give it a title$/) do
  @attachment_title = "My attachment"
  add_attachment_to_manual_document(@document_title, @attachment_title)
end

Then(/^I see the attachment on the page with its example markdown embed code$/) do
  check_for_an_attachment
end

When(/^I copy\+paste the embed code into the body of the case$/) do
  copy_embed_code_for_attachment_and_paste_into_body("My attachment", "#cma_case_body")
end

Then(/^I can see a link to the file with the title in the document preview$/) do
  check_preview_contains_attachment_link(@attachment_title)
end

Then(/^the attachments from the previous edition remain$/) do
  go_to_edit_page_for_cma_case(@document_title)

  check_for_an_attachment
end

Given(/^there is a published case with an attachment$/) do
  @document_title = "Nullam quis risus"
  @attachment_title = "My attachment"

  create_case_with_attachment(@document_title, @attachment_title)
end

When(/^I edit the attachment$/) do
  @new_attachment_title = "And now for something completely different"
  @new_attachment_file_name = "text_file.txt"

  edit_attachment(
    @document_title,
    @attachment_title,
    @new_attachment_title,
    @new_attachment_file_name,
  )
end

Then(/^I see the updated attachment on the document edit page$/) do
  check_for_attachment_update(
    @document_title,
    @new_attachment_title,
    @new_attachment_file_name,
  )
end

Then(/^I see the attached file$/) do
  check_for_an_attachment
end
