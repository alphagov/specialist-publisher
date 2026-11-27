require "spec_helper"

RSpec.describe BulkUnpublishController, type: :controller do
  render_views

  let(:valid_csv) { "base_path,alternative_path\n/cma-cases/one,/somewhere-else\n" }
  let(:content_id) { "11111111-1111-1111-1111-111111111111" }

  before do
    log_in_as FactoryBot.create(:gds_editor)
  end

  describe "GET index" do
    it "responds with a document type select and a field to paste CSV into" do
      get :index

      expect(response.status).to eq(200)
      expect(response.body).to include("document_type_slug")
      expect(response.body).to include("csv_input")
    end

    it "offers the document types the user can access" do
      get :index

      expect(response.body).to include(CmaCase.admin_slug)
      expect(response.body).to include(RaibReport.admin_slug)
    end

    it "redirects a user who is not a GDS editor" do
      log_in_as FactoryBot.create(:cma_editor)

      get :index

      expect(response).to redirect_to(root_path)
      expect(flash[:danger]).to include("aren't permitted")
    end
  end

  describe "POST preview" do
    it "lists what will happen to each document" do
      stub_publishing_api_has_lookups("/cma-cases/one" => content_id)

      post :preview, params: { document_type_slug: "cma-cases", csv_input: valid_csv }

      expect(response.status).to eq(200)
      expect(response.body).to include("/cma-cases/one")
      expect(response.body).to include("Unpublish and redirect to /somewhere-else")
    end

    it "shows the errors and no preview when the CSV is invalid" do
      post :preview, params: { document_type_slug: "cma-cases", csv_input: "base_path,alternative_path\n/raib-reports/one,\n" }

      expect(response.status).to eq(200)
      expect(response.body).to include("is not a CMA Case path")
      expect(response.body).not_to include("Unpublish these documents")
    end

    it "asks for a document type when none was chosen" do
      post :preview, params: { document_type_slug: "", csv_input: valid_csv }

      expect(response.status).to eq(200)
      expect(response.body).to include("Select a document type")
    end

    it "redirects a user who is not a GDS editor" do
      log_in_as FactoryBot.create(:cma_editor)

      post :preview, params: { document_type_slug: "cma-cases", csv_input: valid_csv }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST unpublish" do
    it "queues the bulk unpublishing and says it has started" do
      stub_publishing_api_has_lookups("/cma-cases/one" => content_id)
      user = FactoryBot.create(:gds_editor)
      log_in_as user

      expect(BulkUnpublishWorker).to receive(:perform_async).with("cma-cases", user.id.to_s, valid_csv)

      post :unpublish, params: { document_type_slug: "cma-cases", csv_input: valid_csv }

      expect(response).to redirect_to(bulk_unpublish_path)
      expect(flash[:success]).to include("being unpublished")
    end

    it "does not queue anything when the CSV is invalid" do
      expect(BulkUnpublishWorker).not_to receive(:perform_async)

      post :unpublish, params: { document_type_slug: "cma-cases", csv_input: "base_path,alternative_path\n/raib-reports/one,\n" }

      expect(response.status).to eq(200)
      expect(response.body).to include("is not a CMA Case path")
    end

    it "does not queue anything for a user who is not a GDS editor" do
      log_in_as FactoryBot.create(:cma_editor)

      expect(BulkUnpublishWorker).not_to receive(:perform_async)

      post :unpublish, params: { document_type_slug: "cma-cases", csv_input: valid_csv }

      expect(response).to redirect_to(root_path)
    end
  end
end
