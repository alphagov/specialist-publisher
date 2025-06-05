require "rails_helper"

RSpec.describe UrlHelper, type: :helper do
  describe "#view_on_website_link_for" do
    it "returns document's public link" do
      cma_case = CmaCase.new
      cma_case.title = "cma-1"
      expect(helper.view_on_website_link_for_legacy(cma_case)).to match(%r{<a href="http(s)?://www.(dev|test).gov.uk/cma-cases/cma-1\?cachebust=\d+?">View on website</a>})
    end
  end

  describe "#preview_draft_link_for_legacy" do
    it "returns document's draft link" do
      cma_case = CmaCase.new
      cma_case.title = "cma-1"
      expect(helper.preview_draft_link_for_legacy(cma_case)).to match(%r{<a href="http(s)?://draft-origin.(dev|test).gov.uk/cma-cases/cma-1\?cachebust=\d+?">Preview draft</a>})
    end
  end
end
