Given(/^I am logged in as a "(.*?)" editor$/) do |editor_type|
  login_as(:"#{editor_type.downcase}_editor")
  stub_organisation_details(GDS::SSO.test_user.organisation_slug)
end

Given(/^I am logged in as a non\-CMA editor$/) do
  login_as(:generic_editor)
  stub_organisation_details(GDS::SSO.test_user.organisation_slug)
end

Then(/^I do not see an option for editing documents$/) do
  visit root_path
  check_document_link_not_visible
end

When(/^I attempt to visit a document edit URL$/) do
  visit cma_cases_path
end

Then(/^I am redirected back to the index page$/) do
  expect(current_path).to eq(manuals_path)
end

Then(/^I see a message like "(.*?)"$/) do |message|
  check_page_for_content(message)
end

Given(/^there are manuals created by multiple organisations$/) do

  login_as(:cma_editor)
  stub_organisation_details(GDS::SSO.test_user.organisation_slug)
  @cma_manual_fields = {
    title: "Manual on Competition",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
  }
  create_manual(@cma_manual_fields)

  login_as(:generic_editor)
  stub_organisation_details(GDS::SSO.test_user.organisation_slug)
  @tea_manual_fields = {
    title: "Manual on Tea",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
  }
  create_manual(@tea_manual_fields)

end

When(/^I view my list of manuals$/) do
  visit manuals_path
end

Then(/^I only see manuals created by my organisation$/) do
  check_manual_visible(@tea_manual_fields.fetch(:title))
  check_manual_not_visible(@cma_manual_fields.fetch(:title))
end

Then(/^I see manuals created by all organisations$/) do
  check_manual_visible(@tea_manual_fields.fetch(:title))
  check_manual_visible(@cma_manual_fields.fetch(:title))
end

Given(/^I am logged in as a writer$/) do
  login_as(:cma_writer)
  stub_organisation_details(GDS::SSO.test_user.organisation_slug)
end

Then(/^I can edit cases and manuals$/) do
  check_manual_can_be_created
  check_cma_case_can_be_created
end

Then(/^I cannot publish cases nor manuals$/) do
  check_manual_cannot_be_published
  check_cma_case_cannot_be_published
end

Then(/^I cannot withdraw cases$/) do
  check_cma_case_cannot_be_withdrawn
end
