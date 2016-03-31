require 'spec_helper'

describe EmailAlertPresenter do
  let(:cma_case_payload) { Payloads.cma_case_content_item }
  let(:medical_safety_payload) { Payloads.medical_safety_alert_content_item }

  describe "#to_json" do
    context "any finders document" do
      before do
        publishing_api_has_item(cma_case_payload)
      end

      it "has correct information" do
        cma_case = CmaCase.find(cma_case_payload["content_id"])
        email_alert_presenter = EmailAlertPresenter.new(cma_case)
        presented_data = email_alert_presenter.to_json

        expect(presented_data[:subject]).to include(cma_case_payload["title"])
        expect(presented_data[:body]).to include(cma_case_payload["description"])
        expect(presented_data[:body]).to include(cma_case_payload["title"])
        expect(presented_data[:links]).to eq(topics: [cma_case_payload["content_id"]])
        expect(presented_data[:document_type]).to eq("cma_case")
        expect(presented_data[:footer]).to include("SUBSCRIBER_PREFERENCES_URL")
        expect(presented_data[:header]).to include("govuk-email-header")
      end
    end

    context "Medical Safety Alerts documents" do
      let(:mhra_email_address) { "email.support@mhra.gsi.gov.uk" }

      before do
        publishing_api_has_item(medical_safety_payload)
      end

      it "should use template that contains the email address of MHRA" do
        medical_safety_alert = MedicalSafetyAlert.find(medical_safety_payload["content_id"])
        email_alert_presenter = EmailAlertPresenter.new(medical_safety_alert)
        presented_data = email_alert_presenter.to_json

        expect(presented_data[:body]).to include(mhra_email_address)
        expect(presented_data[:links]).to eq(topics: [medical_safety_payload["content_id"]])
        expect(presented_data[:document_type]).to eq("medical_safety_alert")
      end
    end
  end
end
