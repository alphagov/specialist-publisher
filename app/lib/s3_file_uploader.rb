class S3FileUploader
  def self.save_file_to_s3(filename, csv)
    directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"])

    directory.files.create(
      key: filename,
      body: csv,
    )
  end

  def self.connection
    @connection ||= Fog::Storage.new(
      provider: "AWS",
      region: ENV["AWS_REGION"],
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    )
  end
end
