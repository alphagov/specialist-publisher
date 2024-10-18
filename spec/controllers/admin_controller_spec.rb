require "spec_helper"

RSpec.describe AdminController, type: :controller do
  render_views

  describe "GET summary" do
    it "responds successfully" do
      log_in_as_gds_editor
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      get :summary, params: { document_type_slug: "asylum-support-decisions" }
      expect(response.status).to eq(200)
    end
  end
end
