require "spec_helper"

RSpec.describe FindersController, type: :controller do
  render_views

  describe "GET finder index page" do
    it "renders the finders index table" do
      log_in_as_gds_editor
      get :index
      expect(response.status).to eq(200)
      assert_select "#finders-table-section"
    end
  end

  describe "GET new finder form" do
    it "responds successfully and renders the new finder form" do
      log_in_as_gds_editor
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      get :new
      expect(response.status).to eq(200)
      assert_select "form[action='#{finders_path}'][method='post']"
    end
  end

  describe "POST create finder form" do
    it "responds successfully" do
      log_in_as_gds_editor
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      post :create, params: { email_alert_type: "foo" }
      expect(response.status).to eq(200)
    end
  end

  describe "GET show" do
    it "responds successfully" do
      log_in_as_gds_editor
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      get :show, params: { document_type_slug: "asylum-support-decisions" }
      assert_response :ok
      within "form" do
        assert_select "textarea[name=\"editorial_remark\"]"
      end
    end

    it "denies access for a user without permission to access the finder" do
      log_in_as FactoryBot.create(:cma_editor)
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      get :show, params: { document_type_slug: "asylum-support-decisions" }
      assert_redirected_to root_path
      assert flash[:danger].present?
    end
  end

  describe "GET edit_metadata" do
    it "responds successfully" do
      log_in_as_gds_editor
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      get :edit_metadata, params: { document_type_slug: "asylum-support-decisions" }
      assert_response :ok
    end

    it "denies access for a user without permission to access the finder" do
      log_in_as FactoryBot.create(:cma_editor)
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      get :edit_metadata, params: { document_type_slug: "asylum-support-decisions" }
      assert_redirected_to root_path
      assert flash[:danger].present?
    end
  end

  describe "POST update metadata" do
    it "keeps any existing filter format property even if document title is changed" do
      log_in_as_gds_editor
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      post :update_metadata, params: { document_type_slug: "asylum-support-decisions", email_alert_type: "no", document_title: "Foo Bar" }
      assert_response :ok
      proposed_schema = controller.instance_variable_get(:@proposed_schema)
      expect(proposed_schema.format).to eq("asylum_support_decision")
    end

    it "denies access to user without sufficient permission" do
      log_in_as FactoryBot.create(:cma_editor)
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      post :update_metadata, params: { document_type_slug: "asylum-support-decisions", email_alert_type: "no", document_title: "Foo Bar" }
      assert_redirected_to root_path
      assert flash[:danger].present?
    end

    it "derives filter format from document title, if no filter format yet defined" do
      log_in_as_gds_editor
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      allow(Document).to receive(:finder_schema).and_return(FinderSchema.new)
      allow(Document).to receive(:admin_slug).and_return("some-finder")

      post :update_metadata, params: { document_type_slug: "some-finder", email_alert_type: "no", document_title: "Foo Bar" }
      assert_response :ok
      proposed_schema = controller.instance_variable_get(:@proposed_schema)
      expect(proposed_schema.format).to eq("foo_bar")
    end
  end

  describe "GET edit facets" do
    it "responds successfully" do
      log_in_as_gds_editor
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      get :edit_facets, params: { document_type_slug: "asylum-support-decisions" }
      expect(response.status).to eq(200)
    end

    it "denies access to users with insufficient permission" do
      log_in_as FactoryBot.create(:cma_editor)
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      get :edit_facets, params: { document_type_slug: "asylum-support-decisions" }
      assert_redirected_to root_path
      assert flash[:danger].present?
    end
  end

  describe "POST update facets" do
    it "responds successfully" do
      log_in_as_gds_editor
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      post :update_facets, params: { document_type_slug: "asylum-support-decisions" }
      expect(response.status).to eq(200)
    end

    it "denies access to users with insufficient permission" do
      log_in_as FactoryBot.create(:cma_editor)
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      post :update_facets, params: { document_type_slug: "asylum-support-decisions" }
      assert_redirected_to root_path
      assert flash[:danger].present?
    end
  end
end
