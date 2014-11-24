When(/^I withdraw a CMA case$/) do
  withdraw_cma_case(@document_fields.fetch(:title))
end

Then(/^the CMA case should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @document_fields.fetch(:title))
end
