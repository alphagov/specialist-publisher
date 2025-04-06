require "spec_helper"

RSpec.describe DocumentsController, type: :controller do
  render_views

  let(:payload) { FactoryBot.create(:cma_case) }

  before do
    log_in_as_design_system_gds_editor
    stub_publishing_api_has_item(payload)
  end

  describe "GET show" do
    it "responds successfully" do
      get :show, params: { document_type_slug: "cma-cases", content_id_and_locale: "#{payload['content_id']}:#{payload['locale']}" }
      expect(response.status).to eq(200)
    end

    it "redirects if the URL doesn't include the locale" do
      get :show, params: { document_type_slug: "cma-cases", content_id_and_locale: payload["content_id"] }

      expect(response.status).to eq(301)
      expect(
        URI(response.location).path,
      ).to eq(
        document_path(
          document_type_slug: "cma-cases",
          content_id_and_locale: "#{payload['content_id']}:#{payload['locale']}",
        ),
      )
    end
  end

  describe "POST discard" do
    before do
      stub_publishing_api_discard_draft(payload["content_id"])
    end

    it "responds successfully" do
      post :discard, params: { document_type_slug: "cma-cases", content_id_and_locale: "#{payload['content_id']}:#{payload['locale']}" }
      expect(subject).to redirect_to(documents_path(document_type_slug: "cma-cases"))
    end
  end

  describe "POST create" do
    let(:stub_content_id) { "test-content-id" }

    before do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      expect(SecureRandom).to receive(:uuid).and_return(stub_content_id)
    end

    it "should create a document and send draft to Publishing API" do
      params = {
        "authenticity_token" => "[FILTERED]",
        "data_ethics_guidance_document" => {
          "title" => "test",
          "summary" => "test",
          "body" => "test",
          "locale" => "en",
          "data_ethics_guidance_document_ethical_theme" => [
            "",
            "fairness",
            "societal-wellbeing",
          ],
          "data_ethics_guidance_document_organisation_alias" => [""],
          "data_ethics_guidance_document_project_phase" => [""],
          "data_ethics_guidance_document_technology_area" => [""],
        },
        "save" => "",
        "document_type_slug" => "data-ethics-guidance-documents",
      }

      expected_sent_payload = request_json_includes(
        "details" => {
          "body" => [{ "content_type" => "text/govspeak", "content" => "test" }],
          "metadata" => {
            "data_ethics_guidance_document_ethical_theme" => %w[fairness societal-wellbeing],
          },
          "max_cache_time" => 10,
          "temporary_update_type" => false,
        },
      )

      post :create, params: params

      assert_publishing_api_put_content(stub_content_id, expected_sent_payload)
      expect(subject).to redirect_to(document_path(DataEthicsGuidanceDocument.admin_slug, "#{stub_content_id}:en"))
    end

    it "should handle nested facets when sending draft to Publishing API" do
      params = {
        "authenticity_token" => "[FILTERED]",
        "trademark_decision" => {
          "title" => "Test",
          "summary" => "test",
          "body" => "asdfasdf",
          "locale" => "en",
          "trademark_decision_class" => "1",
          "trademark_decision_date(1i)" => "2020",
          "trademark_decision_date(2i)" => "1",
          "trademark_decision_date(3i)" => "1",
          "trademark_decision_appointed_person_hearing_officer" => "mr-n-abraham",
          "trademark_decision_person_or_company_involved" => "",
          "trademark_decision_grounds_section" => [
            "",
            "section-3-1-graphical-representation-is-it-graphically-represented",
            "section-3-1-graphical-representation-is-it-capable-of-distinguishing",
            "section-3-3-immoral-and-deceptive-marks-deceptive-as-to-nature-quality-etc",
            "procedural-issues",
          ],
        },
        "save" => "",
        "document_type_slug" => "trademark-decisions",
      }

      expected_sent_payload = request_json_includes(
        "details" => {
          "body" => [{ "content_type" => "text/govspeak", "content" => "asdfasdf" }],
          "metadata" => {
            "trademark_decision_class" => "1",
            "trademark_decision_date" => "2020-01-01",
            "trademark_decision_appointed_person_hearing_officer" => "mr-n-abraham",
            "trademark_decision_grounds_section" => [
              "section-3-1-graphical-representation",
              "section-3-3-immoral-and-deceptive-marks",
              "procedural-issues",
            ],
            "trademark_decision_grounds_sub_section" => [
              "section-3-1-graphical-representation-is-it-graphically-represented",
              "section-3-1-graphical-representation-is-it-capable-of-distinguishing",
              "section-3-3-immoral-and-deceptive-marks-deceptive-as-to-nature-quality-etc",
            ],
          },
          "max_cache_time" => 10,
          "temporary_update_type" => false,
        },
      )

      post :create, params: params

      assert_publishing_api_put_content(stub_content_id, expected_sent_payload)
      expect(subject).to redirect_to(document_path(TrademarkDecision.admin_slug, "#{stub_content_id}:en"))
    end
  end
end
