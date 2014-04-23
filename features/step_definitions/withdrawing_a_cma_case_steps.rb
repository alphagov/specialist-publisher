When(/^I withdraw a CMA case$/) do
  withdraw_document(@cma_fields.fetch(:title))
end

Then(/^the CMA case should be withdrawn$/) do
  visit specialist_documents_path
  click_link @cma_fields.fetch(:title)
  expect(page).to have_content("Publication state: withdrawn")
end
