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
  pending # express the regexp above with the code you wish you had
end

Then(/^I can see a link to the file with the title in the document preview$/) do
  pending # express the regexp above with the code you wish you had
end