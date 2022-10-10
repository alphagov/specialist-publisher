require "rails_helper"

RSpec.describe DocumentListExportRequestController, type: :controller do
  before do
    log_in_as_gds_editor

    Fog.mock!
    ENV["AWS_REGION"] = "eu-west-1"
    ENV["AWS_ACCESS_KEY_ID"] = "test"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test"
    ENV["AWS_S3_BUCKET_NAME"] = "test-bucket"

    # Create an S3 bucket so the code being tested can find it
    connection = Fog::Storage.new(
      provider: "AWS",
      region: ENV["AWS_REGION"],
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    )
    @directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"]) || connection.directories.create(key: ENV["AWS_S3_BUCKET_NAME"])
  end

  describe "GET show" do
    it "responds successfully if there is a valid file" do
      document_type_slug = "asylum-support-decisions"
      export_id = "1234-5678"
      filename = "document_list_#{document_type_slug}_#{export_id}.csv"

      @directory.files.create(key: filename, body: "hello world")

      get :show, params: { document_type_slug:, export_id: }
      expect(response.status).to eq(200)
      expect(response.body).to eq("hello world")
    end

    it "returns an error if there is no request" do
      get :show, params: { document_type_slug: "asylum-support-decisions", export_id: "aaaa-bbbb" }
      expect(response.status).to eq(404)
    end
  end
end
