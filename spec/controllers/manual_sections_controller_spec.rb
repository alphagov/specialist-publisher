require "spec_helper"

RSpec.describe ManualSectionsController, type: :controller do
  before do
    log_in_as_gds_editor
  end

  describe "GET show" do
    let(:content_id) { SecureRandom.uuid }
    let(:manual_content_id) { SecureRandom.uuid }
    let(:section) do
      double(:section,
            content_id: content_id,
            manual_content_id: manual_content_id)
    end

    context "with valid manual and section content_ids" do
      before do
        allow(Section).to receive(:find)
          .with(content_id: content_id, manual_content_id: manual_content_id)
          .and_return(section)
      end

      it "is successful" do
        get :show, content_id: content_id, manual_content_id: manual_content_id
        expect(response).to be_successful
      end
    end

    context "with an invalid manual content_id for the section" do
      let(:invalid_manual_content_id) { SecureRandom.uuid }

      before do
        allow(Section).to receive(:find)
          .with(content_id: content_id, manual_content_id: invalid_manual_content_id)
          .and_raise(Section::RecordNotFound)
      end

      it "responds with section manual not found" do
        get :show, content_id: content_id, manual_content_id: invalid_manual_content_id

        expect(response).to redirect_to(manuals_path)
      end
    end

    context "with an invalid content_id for the section" do
      let(:invalid_content_id) { SecureRandom.uuid }

      before do
        allow(Section).to receive(:find)
          .with(content_id: invalid_content_id, manual_content_id: manual_content_id)
          .and_raise(Section::RecordNotFound)
      end

      it "responds with section not found" do
        get :show, content_id: invalid_content_id, manual_content_id: manual_content_id

        expect(response).to redirect_to(manuals_path)
      end
    end
  end
end
