require "spec_helper"

RSpec.describe FindersController, type: :controller do
  render_views

  context "when the user has permission to view the design system layout" do
    describe "GET finder index page" do
      it "renders the finders index table" do
        log_in_as_design_system_gds_editor
        get :index
        expect(response.status).to eq(200)
        assert_select "#finders-table-section"
      end
    end

    describe "GET new finder form" do
      it "responds successfully and renders the new finder form" do
        log_in_as_design_system_gds_editor
        stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
        get :new
        expect(response.status).to eq(200)
        assert_select "form[action='#{finders_path}'][method='post']"
      end
    end

    describe "POST create finder form" do
      it "responds successfully" do
        log_in_as_design_system_gds_editor
        stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
        post :create, params: { email_alert_type: "foo" }
        expect(response.status).to eq(200)
      end
    end
  end
end
