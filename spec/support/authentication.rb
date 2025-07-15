module AuthenticationControllerHelpers
  def log_in_as(user)
    request.env["warden"] = double(
      :auth,
      authenticate!: true,
      authenticated?: true,
      user:,
    )
    user
  end

  def log_in_as_gds_editor
    log_in_as FactoryBot.create(:gds_editor)
  end
end
RSpec.configuration.include AuthenticationControllerHelpers, type: :controller

module AuthenticationFeatureHelpers
  def log_in_as(user)
    GDS::SSO.test_user = user
  end

  def log_in_as_editor(user_type, organisation_content_id = nil)
    user = FactoryBot.create(user_type)
    user.organisation_content_id = organisation_content_id if organisation_content_id
    log_in_as user
  end
end
RSpec.configuration.include AuthenticationFeatureHelpers, type: :feature
