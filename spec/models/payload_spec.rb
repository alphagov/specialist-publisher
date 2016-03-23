require "rails_helper"

# Validate payloads
RSpec.describe Payloads do
  describe ".cma_case_content_item" do
    it "is valid against the content schema" do
      expect(Payloads.cma_case_content_item).to be_valid_against_schema("specialist_document")
    end
  end
end
