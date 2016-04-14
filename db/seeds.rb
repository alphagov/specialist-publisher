if Rails.env.development?
  # Setup a mock user
  User.create(name: "Test user", permissions: ["signin", "gds_editor"])
end
