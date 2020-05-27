def seed
  return unless Rails.env.development? || ENV["RUN_SEEDS_IN_PRODUCTION"]
  return if User.where(name: "Test user").present?

  gds_organisation_id = "af07d5a5-df63-4ddc-9383-6a666845ebe9"

  User.create!(
    name: "Test user",
    permissions: %w[signin gds_editor],
    organisation_content_id: gds_organisation_id,
  )
end

seed
