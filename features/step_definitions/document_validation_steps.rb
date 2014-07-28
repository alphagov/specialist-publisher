Then(/^I should see error messages about missing fields$/) do
  check_for_missing_title_error
  check_for_missing_summary_error
end

Then(/^I should see an error message about an invalid date field "(.*)"$/) do |field|
  check_for_invalid_date_error(field)
end

Then(/^I should see an error message about the duplicate slug$/) do
  check_for_error("Slug is already taken")
end

Then(/^I should see an error message about a "(.*?)" field containing javascript$/) do |field|
  check_for_javascript_usage_error(field)
end
