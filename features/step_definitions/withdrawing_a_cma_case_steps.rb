When(/^I withdraw a CMA case$/) do
  withdraw_document(@cma_fields.fetch(:title))
end

Then(/^the CMA case should be withdrawn$/) do
  check_document_is_withdrawn(@cma_fields.fetch(:title))
end
