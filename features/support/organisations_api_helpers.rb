require "gds_api/test_helpers/organisations"

module OrganisationsAPIHelpers
  include GdsApi::TestHelpers::Organisations
  def stub_organisation_details(organisation_slug)
    organisations_api_has_organisation(organisation_slug)
  end
end
RSpec.configuration.include OrganisationsAPIHelpers, type: :feature
