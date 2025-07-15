require "spec_helper"

RSpec.describe PassthroughController, type: :controller do
  render_views

  let(:user) { FactoryBot.create(:gds_editor) }

  context "when the user has permission to view the design system layout" do
    it "redirects the user to the finders index page" do
      log_in_as_gds_editor
      get :index
      expect(response.status).to eq(302)
      expect(response.location).to eq(finders_url)
    end
  end
end
