require "rails_helper"

RSpec.describe UrlHelper, type: :helper do
  describe "#view_on_website_link_for" do
    it "returns document's public link" do
      manual = Manual.new.tap { |doc| doc.base_path = "/guidance/abc" }
      expect(helper.view_on_website_link_for(manual)).to match(%r{<a href="http(s)?://www.(dev|test).gov.uk/guidance/abc\?cachebust=\d+?">View on website</a>})
    end
  end

  describe "#preview_draft_link_for" do
    it "returns document's draft link" do
      manual = Manual.new.tap { |doc| doc.base_path = "/guidance/abc" }
      expect(helper.preview_draft_link_for(manual)).to match(%r{<a href="http(s)?://draft-origin.(dev|test).gov.uk/guidance/abc\?cachebust=\d+?">Preview draft</a>})
    end
  end
end
