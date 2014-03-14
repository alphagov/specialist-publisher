Given(/^there is an existing draft case$/) do
  create_cma_case(
    title: "Nullam quis risus",
    summary: 'Eget urna mollis ornare vel eu leo.',
    body: ('Praesent commodo cursus magna, vel scelerisque nisl consectetur et.' * 10),
    opened_date: '2014-01-01'
  )
end

When(/^I attach a file and give it a title$/) do
  add_attachment_to_case("Nullam quis risus")
end

Then(/^I see the attachment on the case with its example markdown embed code$/) do
  check_for_an_attachment
end

When(/^I copy\+paste the embed code into the body of the case$/) do
  copy_embed_code_for_attachment_and_paste_into_body("My attachment")
end

Then(/^I can see a link to the file with the title in the document preview$/) do
  generate_preview
  check_preview_contains_attachment_link("My attachment")
end

Then(/^the attachments from the previous edition remain$/) do
  go_to_edit_page_for_most_recent_case

  check_for_an_attachment
end
