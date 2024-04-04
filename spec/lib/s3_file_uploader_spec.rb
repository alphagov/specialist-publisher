require "spec_helper"

RSpec.describe S3FileUploader do
  let(:stubbed_client) { Aws::S3::Client.new(stub_responses: true) }

  before do
    @mock_bucket = {}
    stubbed_client = Aws::S3::Client.new(stub_responses: true)
    allow(Aws::S3::Client).to receive(:new).and_return(stubbed_client)

    mock_s3_bucket(stubbed_client, @mock_bucket)
    ENV["AWS_S3_BUCKET_NAME"] = "test-bucket"
  end

  it "has the expected filename and content" do
    filename = "test_file_name.txt"
    body = "hello, world\n"
    described_class.save_file_to_s3(filename, body)

    obj = stubbed_client.get_object(
      bucket: ENV["AWS_S3_BUCKET_NAME"],
      key: filename,
    )
    expect(obj.body.read).to eq body
  end
end
