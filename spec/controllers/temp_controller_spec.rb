require "spec_helper"

RSpec.describe TempController, type: :controller do
  render_views

  before do
    log_in_as_gds_editor
  end

  describe "GET show" do
    it "responds successfully" do
      get :index
      expect(response.status).to eq(200)
    end
  end
end
