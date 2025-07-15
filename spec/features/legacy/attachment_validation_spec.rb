require "spec_helper"

RSpec.feature "Validating inline attachments", type: :feature do
  before do
    log_in_as_editor(:cma_editor)
  end

  before(:each) do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:show_design_system, false)
  end

  after(:each) do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:show_design_system, true)
  end

  scenario "creating a document that references attachments that don't exist" do
    visit "/cma-cases/new"
    fill_in "Body", with: "[InlineAttachment:missing.pdf]"
    click_button "Save"

    expect(page).to have_content("There is a problem")
    expect(page).to have_content(
      "Body contains an attachment that can't be found: 'missing.pdf'",
    )
  end

  scenario "escaping inline attachments so that they are html safe" do
    visit "/cma-cases/new"
    fill_in "Body", with: "[InlineAttachment:<not>safe.pdf]"
    click_button "Save"

    expect(page).to have_content("There is a problem")

    expect(page).to have_content(
      "Body contains an attachment that can't be found: '<not>safe.pdf'",
    )
    expect(page).not_to have_content(
      "Body contains an attachment that can't be found: '&lt;not&gt;safe.pdf'",
    )
  end
end
