require "rails_helper"

RSpec.describe DocumentListExportRequestController, type: :controller do
  let(:stubbed_client) { Aws::S3::Client.new(stub_responses: true) }
  before do
    log_in_as_gds_editor

    allow(Aws::S3::Client).to receive(:new).and_return(stubbed_client)

    ENV["AWS_S3_BUCKET_NAME"] = "test-bucket"
  end

  describe "GET show" do
    it "responds successfully if there is a valid file" do
      document_type_slug = "asylum-support-decisions"
      export_id = "1234-5678"

      stubbed_client.stub_responses(:get_object, { body: "hello world" })

      get :show, params: { document_type_slug:, export_id: }
      expect(response.status).to eq(200)
      expect(response.body).to eq("hello world")
    end

    it "returns an error if there is no request" do
      stubbed_client.stub_responses(:get_object, "NoSuchKey")

      get :show, params: { document_type_slug: "asylum-support-decisions", export_id: "aaaa-bbbb" }
      expect(response.status).to eq(404)
    end
  end
end
