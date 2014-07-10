When(/^I withdraw a CMA case$/) do
  withdraw_cma_case(@cma_fields.fetch(:title))
end

Then(/^the CMA case should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @cma_fields.fetch(:title))
end
