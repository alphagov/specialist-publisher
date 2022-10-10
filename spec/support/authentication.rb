module AuthenticationControllerHelpers
  def log_in_as(user)
    request.env["warden"] = double(
      :auth,
      authenticate!: true,
      authenticated?: true,
      user:,
    )
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

  def log_in_as_editor(user_type)
    log_in_as FactoryBot.create(user_type)
  end
end
RSpec.configuration.include AuthenticationFeatureHelpers, type: :feature
