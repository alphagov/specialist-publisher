class S3FileUploader
  def self.save_file_to_s3(filename, csv)
    s3 = Aws::S3::Client.new

    s3.put_object({
      key: filename,
      body: csv,
      bucket: ENV["AWS_S3_BUCKET_NAME"],
      content_disposition: "attachment; filename=\"#{filename}\"",
      content_type: "text/csv",
    })
  end
end
