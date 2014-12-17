Then(/^a publication notification should have been sent$/) do
  check_email_alert_api_notified_of_publish
end

Then(/^a publication notification should not have been sent$/) do
  check_email_alert_api_is_not_notified_of_publish
end
