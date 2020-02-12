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
      filename = "test.txt"
      @directory.files.create(key: filename, body: "hello world")
      export_request = DocumentListExportRequest.new(filename: filename, document_class: "asylum-support-decisions")
      export_request.save!
      export_request.touch(:generated_at)

      get :show, params: { id: export_request.id }
      expect(response.status).to eq(200)
      expect(response.body).to eq("hello world")
    end

    it "returns an error if there is no request" do
      get :show, params: { id: "no-such-id" }
      expect(response.status).to eq(404)
    end
  end
end
