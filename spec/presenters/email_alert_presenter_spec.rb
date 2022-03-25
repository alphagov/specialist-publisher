require "spec_helper"

RSpec.describe EmailAlertPresenter do
  let(:cma_case_payload) { FactoryBot.create(:cma_case) }
  let(:medical_safety_payload) { FactoryBot.create(:medical_safety_alert) }
  let(:cma_case_redrafted_payload) { FactoryBot.create(:cma_case, :redrafted, title: "updated") }

  let(:product_safety_alert_payload) { FactoryBot.create(:product_safety_alert_report_recall) }

  describe "#to_json" do
    context "product_safety_alert_report_recall finder" do
      before do
        stub_publishing_api_has_item(product_safety_alert_payload)
      end

      it "does not send the links hash in the payload for email alert api" do
        product_safety_alert = ProductSafetyAlertReportRecall.find(product_safety_alert_payload["content_id"], product_safety_alert_payload["locale"])
        email_alert_presenter = described_class.new(product_safety_alert)
        presented_data = email_alert_presenter.to_json
        expect(presented_data[:tags][:format]).to eq(product_safety_alert_payload["document_type"])
        expect(presented_data[:tags][:case_type]).to eq(product_safety_alert_payload["details"]["metadata"]["case_type"])
        expect(presented_data[:links]).to eq({})
      end
    end

    context "any finders document" do
      before do
        stub_publishing_api_has_item(cma_case_payload)
        stub_publishing_api_has_item(cma_case_redrafted_payload)
      end

      it "has correct information" do
        cma_case = CmaCase.find(cma_case_payload["content_id"], cma_case_payload["locale"])
        email_alert_presenter = EmailAlertPresenter.new(cma_case)
        presented_data = email_alert_presenter.to_json

        redrafted_cma_case = CmaCase.find(cma_case_redrafted_payload["content_id"], cma_case_redrafted_payload["locale"])
        email_alert_presenter_redrafted = EmailAlertPresenter.new(redrafted_cma_case)
        presented_data_redrafted = email_alert_presenter_redrafted.to_json

        cma_links = DocumentLinksPresenter.new(cma_case).to_json[:links]

        expect(presented_data[:title]).to include(cma_case_payload["title"])
        expect(presented_data[:description]).to include(cma_case_payload["description"])
        expect(presented_data[:subject]).to include(cma_case_payload["title"])
        expect(presented_data[:subject]).not_to include("updated")
        expect(presented_data_redrafted[:subject]).to include("updated")
        expect(presented_data[:tags][:format]).to eq(cma_case_payload["document_type"])
        expect(presented_data[:tags][:case_type]).to eq(cma_case_payload["details"]["metadata"]["case_type"])
        expect(presented_data[:document_type]).to eq(cma_case_payload["document_type"])
        expect(presented_data[:links]).to eq(cma_links)
        expect(presented_data[:public_updated_at]).to include(cma_case_payload["public_updated_at"])
        expect(presented_data[:base_path]).to include(cma_case_payload["base_path"])
        expect(presented_data[:priority]).to eq("normal")

        expect(presented_data.keys).to match_array(%i[
          title
          description
          change_note
          subject
          tags
          document_type
          email_document_supertype
          government_document_supertype
          content_id
          public_updated_at
          publishing_app
          base_path
          urgent
          priority
          links
        ])
      end
    end

    it "removes hidden indexable content from tags" do
      asylum_support_decision_payload = FactoryBot.create(:asylum_support_decision)
      stub_publishing_api_has_item(asylum_support_decision_payload)
      asylum_support_decision = AsylumSupportDecision.find(asylum_support_decision_payload["content_id"], asylum_support_decision_payload["locale"])
      expect(asylum_support_decision.format_specific_metadata.keys)
        .to include(:hidden_indexable_content)

      presented_data = EmailAlertPresenter.new(asylum_support_decision).to_json
      expect(presented_data[:tags])
        .not_to include(:hidden_indexable_content)
    end

    context "Medical Safety Alerts documents" do
      let(:mhra_email_address) { "email.support@mhra.gov.uk" }

      before do
        stub_publishing_api_has_item(medical_safety_payload)
      end

      it "should use template that contains the email address of MHRA" do
        medical_safety_alert = MedicalSafetyAlert.find(medical_safety_payload["content_id"], medical_safety_payload["locale"])
        email_alert_presenter = EmailAlertPresenter.new(medical_safety_alert)
        presented_data = email_alert_presenter.to_json

        expect(presented_data[:document_type]).to eq("medical_safety_alert")
        expect(presented_data[:priority]).to eq("high")
        expect(presented_data[:footnote]).to eq("If you have any questions about the medical content in this email, contact MHRA on info@mhra.gov.uk")
      end
    end
  end
end
