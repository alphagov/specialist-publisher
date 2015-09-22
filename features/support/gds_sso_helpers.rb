require "warden/test/helpers"

module GdsSsoHelpers
  include Warden::Test::Helpers

  def login_as(user_type)
    user = FactoryGirl.create(user_type.to_sym)
    GDS::SSO.test_user = user
    super(user) # warden
  end

  def log_out
    GDS::SSO.test_user = nil
    logout # warden
  end
end
RSpec.configuration.include GdsSsoHelpers, type: :feature
