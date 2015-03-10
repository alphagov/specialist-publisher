require "spec_helper"

describe ManualsController, type: :controller do
  describe "#publish" do
    let(:manual_id) { "manual-1" }
    before do
      login_as_stub_user
      allow_any_instance_of(PermissionChecker).to receive(:can_edit?).and_return(true)
      allow_any_instance_of(PermissionChecker).to receive(:can_publish?).and_return(false)
      allow(ManualsController).to receive(:publish)
      post :publish, id: manual_id
    end

    it "redirects to the manual's show page" do
      expect(response).to redirect_to manual_path(id: manual_id)
    end

    it "sets a flash message" do
      expect(flash[:error]).to include("You don't have permission to")
    end

    it "does not publish the manual" do
      expect(ManualsController).not_to have_received(:publish)
    end
  end
end
