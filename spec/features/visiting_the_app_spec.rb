require 'spec_helper'

RSpec.feature "Visiting the app", type: :feature do
  let(:fields) { %i[content_id description title details public_updated_at publication_state base_path update_type] }

  before do
    log_in_as_editor(:cma_editor)
    publishing_api_has_content([], document_type: "manual", fields: fields, per_page: Manual.max_numbers_of_manuals)
  end

  scenario "visiting / should redirect to manuals" do
    visit "/"
    expect(page).to have_content("Your manuals (0)")
  end

  scenario "visiting any path should set an authenticated user header" do
    visit "/"
    expect(/uid-\d+/).to match(GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user])
  end
end
