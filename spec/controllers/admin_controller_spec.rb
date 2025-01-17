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

  describe "GET edit facets" do
    it "responds successfully" do
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      get :edit_facets, params: { document_type_slug: "asylum-support-decisions" }
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

  describe "POST edit facets" do
    it "responds successfully" do
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      post :edit_facets, params: { document_type_slug: "asylum-support-decisions" }
      expect(response.status).to eq(200)
    end
  end

  describe "POST zendesk" do
    it "responds successfully, calling support api" do
      # TODO: re-enable the more detailed hash comparison check
      stub_post = stub_support_api_valid_raise_support_ticket(anything)
      # stub_post = stub_support_api_valid_raise_support_ticket(hash_including({
      #   subject: "Specialist Finder Edit Request: CMA Cases",
      #   tags: %w[specialist_finder_edit_request],
      #   priority: "normal",
      #   requester: { name: user.name, email: user.email },
      #   description: /^Developer - raise a PR replacing this schema with the schema below: https:\/\/github\.com\/alphagov\/specialist-publisher\/edit\/main\/lib\/documents\/schemas\/cma_cases\.json\r\n---\r\n```\r\n{/,
      # }))

      # TODO: find some way of asserting that the JSON sent has been beautified
      # WebMock.after_request do |request_signature, response|
      #   submitted_json = request_signature.body.match(some regex)[1]
      #   expect(submitted_json).to eq(JSON.pretty_generate(CmaCase.finder_schema.to_json))
      # end
      post :zendesk, params: { document_type_slug: "cma-cases", proposed_schema: CmaCase.finder_schema.to_json }

      assert_requested(stub_post)
    end
  end
end
