require "spec_helper"

RSpec.feature "Visiting the app", type: :feature do
  before do
    log_in_as_editor(:cma_editor)
    stub_publishing_api_has_content([], hash_including(document_type: CmaCase.document_type))
  end

  before(:each) do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:show_design_system, false)
  end

  after(:each) do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:show_design_system, true)
  end

  scenario "visiting any path should set an authenticated user header" do
    visit "/"
    expect(/uid-\d+/).to match(GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user])
  end
end
