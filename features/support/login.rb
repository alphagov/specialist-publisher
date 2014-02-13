def login_as(user_type)
  user = FactoryGirl.create(user_type.to_sym)
  GDS::SSO.test_user = user
end
