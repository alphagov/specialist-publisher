GovukAdminTemplate.configure do |c|
  c.app_title = "Specialist Publisher"
  c.show_flash = true
  c.show_signout = true
end

GovukAdminTemplate.environment_label = ENV.fetch("GOVUK_ENVIRONMENT_NAME", "development").titleize
GovukAdminTemplate.environment_style = ENV["GOVUK_ENVIRONMENT_NAME"] == "production" ? "production" : "preview"
