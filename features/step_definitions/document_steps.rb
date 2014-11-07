Then(/^an email alert should not be sent$/) do
  expect(fake_email_alert_api).to_not have_received(:send_alert)
end
