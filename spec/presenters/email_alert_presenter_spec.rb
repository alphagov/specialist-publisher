require 'spec_helper'

describe EmailAlertPresenter do
  let(:document) { Payloads.cma_case_content_item }
  describe "#to_json" do
    before do
      publishing_api_has_item(document)
    end

    it "has correct information" do
      cma_case = CmaCase.find(document["content_id"])
      email_alert_presenter = EmailAlertPresenter.new(cma_case)
      presented_data = email_alert_presenter.to_json

      expect(presented_data[:subject]).to include(document["title"])
      expect(presented_data[:body]).to include(document["description"])
      expect(presented_data[:body]).to include(document["title"])
      expect(presented_data[:links]).to eq(topics: [document["content_id"]])
      expect(presented_data[:document_type]).to eq("cma_case")
    end
  end
end
