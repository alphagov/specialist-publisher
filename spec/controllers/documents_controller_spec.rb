require "spec_helper"

RSpec.describe DocumentsController, type: :controller do
  render_views

  let(:payload) { FactoryGirl.create(:cma_case) }

  before do
    log_in_as_gds_editor
    publishing_api_has_item(payload)
  end

  describe "GET show" do
    it "responds successfully" do
      get :show, document_type_slug: "cma-cases", content_id: payload["content_id"]
      expect(response.status).to eq(200)
    end
  end
end
