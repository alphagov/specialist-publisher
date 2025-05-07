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

  def log_in_as_design_system_gds_editor
    user = FactoryBot.create(:gds_editor)
    user.permissions << "preview_design_system"
    log_in_as user
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

  def log_in_as_design_system_editor(user_type)
    user = FactoryBot.create(user_type)
    user.permissions << "preview_design_system"
    log_in_as user
  end
end
RSpec.configuration.include AuthenticationFeatureHelpers, type: :feature
