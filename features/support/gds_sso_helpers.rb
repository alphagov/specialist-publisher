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

  def as_user(user)
    original_user = GDS::SSO.test_user
    login_as(user)
    yield
    login_as(original_user)
  end
end
