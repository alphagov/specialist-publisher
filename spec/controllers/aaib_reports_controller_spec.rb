require "spec_helper"

# This is intended to test that access controls are properly set up on the
# AbstractDocumentsController. It's infeasible to test that controller directly,
# or to set up a complete document format for use in tests. Instead we're
# testing access controls via the AaibReportsController because at the moment
# this format is relatively generic.
describe AaibReportsController, type: :controller do
  shared_examples "prevents editing without permission" do
    before do
      login_as_stub_user
      allow_any_instance_of(PermissionChecker).to receive(:can_edit?).and_return(false)
      make_request
    end

    it "redirects to the manuals page" do
      expect(response).to redirect_to manuals_path
    end

    it "sets a flash message" do
      expect(flash[:error]).to include("You don't have permission to")
    end
  end

  describe "#create" do
    context "without permission to edit" do
      def make_request
        post :create
      end

      it_behaves_like "prevents editing without permission"
    end
  end

  describe "#update" do
    context "without permission to edit" do
      def make_request
        post :update
      end

      it_behaves_like "prevents editing without permission"
    end
  end

  describe "publishing and withdrawing" do
    before do
      login_as_stub_user
      allow_any_instance_of(PermissionChecker).to receive(:can_edit?).and_return(true)
      @edition = FactoryGirl.create(
        :specialist_document_edition,
        document_id: "document-id-1",
        document_type: "aaib_report",
        updated_at: 2.days.ago
      )
    end

    describe "#publish" do
      before do
        allow(AaibReportsController).to receive(:publish)
        allow_any_instance_of(PermissionChecker).to receive(:can_publish?).and_return(false)
        post :publish, id: @edition.document_id
      end

      it "redirects to the document's show page" do
        expect(response).to redirect_to aaib_report_path
      end

      it "sets a flash message" do
        expect(flash[:error]).to include("You don't have permission to")
      end

      it "does not publish the document" do
        expect(AaibReportsController).not_to have_received(:publish)
      end
    end

    describe "#withdraw" do
      before do
        allow(AaibReportsController).to receive(:withdraw)
        allow_any_instance_of(PermissionChecker).to receive(:can_withdraw?).and_return(false)
        post :withdraw, id: @edition.document_id
      end

      it "redirects to the document's show page" do
        expect(response).to redirect_to aaib_report_path
      end

      it "sets a flash message" do
        expect(flash[:error]).to include("You don't have permission to")
      end

      it "does not withdraw the document" do
        expect(AaibReportsController).not_to have_received(:withdraw)
      end
    end
  end
end
