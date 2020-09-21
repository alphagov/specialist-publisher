require "spec_helper"

RSpec.describe DocumentsController, type: :controller do
  render_views

  let(:payload) { FactoryBot.create(:cma_case) }

  before do
    log_in_as_gds_editor
    stub_publishing_api_has_item(payload)
  end

  describe "GET show" do
    it "responds successfully" do
      get :show, params: { document_type_slug: "cma-cases", content_id_and_locale: "#{payload["content_id"]}:#{payload["locale"]}" }
      expect(response.status).to eq(200)
    end
  end

  describe "POST discard" do
    before do
      stub_publishing_api_discard_draft(payload["content_id"])
    end

    it "responds successfully" do
      post :discard, params: { document_type_slug: "cma-cases", content_id_and_locale: "#{payload["content_id"]}:#{payload["locale"]}" }
      expect(subject).to redirect_to(documents_path(document_type_slug: "cma-cases"))
    end
  end
end
