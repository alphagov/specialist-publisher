require "spec_helper"

RSpec.describe PassthroughController, type: :controller do
  render_views

  let(:user) { FactoryBot.create(:gds_editor) }

  context "when the user has permission to view the design system layout" do
    it "renders the finders table" do
      log_in_as_design_system_gds_editor
      get :index
      expect(response.status).to eq(200)
      assert_select "#finders-table-section"
    end
  end
end
