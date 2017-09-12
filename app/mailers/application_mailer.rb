class ApplicationMailer < ActionMailer::Base
  default from: Proc.new { no_reply_email_address }

  def no_reply_email_address
    name = "GOV.UK publishing"
    if GovukAdminTemplate.environment_label !~ /production/i
      name.prepend("[GOV.UK #{GovukAdminTemplate.environment_label}] ")
    end

    address = Mail::Address.new("inside-government@digital.cabinet-office.gov.uk")
    address.display_name = name
    address.format
  end
end
