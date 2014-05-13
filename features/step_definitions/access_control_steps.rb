Given(/^I am logged in as a non\-CMA editor$/) do
  login_as(:generic_editor)

  # WARNING: These must be stubbed before the first request takes place
  stub_out_panopticon
  stub_finder_api
end

Then(/^I do not see an option for editing documents$/) do
  visit root_path
  expect(page).not_to have_css('a', text: 'Documents')
end

When(/^I attempt to visit a document edit URL$/) do
  visit specialist_documents_path
end

Then(/^I am redirected back to the index page$/) do
  expect(current_path).to eq(manuals_path)
end

Then(/^I see a message like "(.*?)"$/) do |message|
  expect(page).to have_content(message)
end
