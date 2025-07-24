require "rails_helper"

RSpec.describe UrlHelper, type: :helper do
  describe "#public_url_for" do
    it "returns document's public link" do
      cma_case = CmaCase.new
      cma_case.title = "cma-1"
      expect(helper.public_url_for(cma_case)).to match(%r{http(s)?://www\.(dev|test)\.gov\.uk/cma-cases/cma-1\?cachebust=\d+?})
    end
  end

  describe "#draft_url_for" do
    it "returns document's draft link" do
      cma_case = CmaCase.new
      cma_case.title = "cma-1"
      expect(helper.draft_url_for(cma_case)).to match(%r{http(s)?://draft-origin\.(dev|test)\.gov\.uk/cma-cases/cma-1\?cachebust=\d+?})
    end
  end
end
