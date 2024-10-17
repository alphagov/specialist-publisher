require "spec_helper"

RSpec.feature "Visiting a design system page", type: :feature do
  before do
    log_in_as_editor(:gds_editor)
  end

  scenario "visiting /design-system should display a temporary page" do
    visit "/design-system"
    expect(page).to have_selector(".govuk-header__product-name", text: "Specialist Publisher")
    expect(page).to have_selector("label", text: "Field checking ES6 module javascript")
    expect(page).to have_selector("label", text: "Field checking regular javascript")
  end
end
