require "spec_helper"
require "gds_api/test_helpers/support_api"

RSpec.describe AdminController, type: :controller do
  include GdsApi::TestHelpers::SupportApi

  render_views

  let(:user) { FactoryBot.create(:gds_editor) }

  before do
    log_in_as user
  end

  describe "GET summary" do
    it "responds successfully" do
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      get :summary, params: { document_type_slug: "asylum-support-decisions" }
      expect(response.status).to eq(200)
    end
  end

  describe "GET edit metadata" do
    it "responds successfully" do
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      get :edit_metadata, params: { document_type_slug: "asylum-support-decisions" }
      expect(response.status).to eq(200)
    end
  end

  describe "POST edit metadata" do
    it "responds successfully" do
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      post :edit_metadata, params: { document_type_slug: "asylum-support-decisions" }
      expect(response.status).to eq(200)
    end
  end

  describe "POST zendesk" do
    it "responds successfully, calling support api" do
      stub_post = stub_support_api_valid_raise_support_ticket(hash_including({
        subject: "Specialist Finder Edit Request: CMA Cases",
        tags: %w[specialist_finder_edit_request],
        priority: "normal",
        requester: { name: user.name, email: user.email },
      }))

      post :zendesk, params: { document_type_slug: "cma-cases", proposed_schema: CmaCase.finder_schema.schema }

      assert_requested(stub_post)
    end
  end
end
