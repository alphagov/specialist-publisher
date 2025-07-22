class ApplicationMailer < Mail::Notify::Mailer
  default from: proc { no_reply_email_address }

  def no_reply_email_address
    name = "GOV.UK publishing"
    environment = GovukPublishingComponents::AppHelpers::Environment.current_acceptance_environment
    if environment !~ /production/i
      name.prepend("[GOV.UK #{environment}] ")
    end

    address = Mail::Address.new("inside-government@digital.cabinet-office.gov.uk")
    address.display_name = name
    address.format
  end

  def template_id
    @template_id ||= ENV.fetch("GOVUK_NOTIFY_TEMPLATE_ID", "fake-test-template-id")
  end
end
