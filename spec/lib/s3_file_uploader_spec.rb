require "spec_helper"

RSpec.describe S3FileUploader do
  before do
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

  it "has the expected filename and content" do
    s3_file = described_class.save_file_to_s3("test_file_name.txt", "hello, world\n")
    expect(s3_file.key).to eq "test_file_name.txt"
    file = @directory.files.get("test_file_name.txt")
    expect(file).not_to be nil
    expect(file.body).to eq "hello, world\n"
  end
end
