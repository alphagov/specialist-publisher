require "rails_helper"
require "spec_helper"

RSpec.describe FindersListComponent, type: :component do
  it "renders" do
    finders = FactoryBot.build_list(:finder_schema, 3)
    render_inline(FindersListComponent.new(finders))
    expect(page).to have_selector("#finders-list-section")
    finders.each_with_index do |finder, index|
      row = page.find_css("#finders-list-section li:nth-child(#{index + 1})")
      expect(row).to have_link(finder.document_title.pluralize, href: finder_path(finder.admin_slug))
    end
  end
end
