class DocumentListExportRequestController < ApplicationController
  before_action :check_authorisation
  def show
    begin
      response = DocumentListExportRequest.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      head :not_found
      return
    end

    if response.ready?
      file = get_csv_file_from_s3(response.filename)
      send_data(file, filename: response.filename)
    else
      head :not_found
    end
  end

  def check_authorisation
    begin
      document_type_slug = DocumentListExportRequest.find(params[:id]).document_class
    rescue Mongoid::Errors::DocumentNotFound
      head :not_found
      return
    end

    document_slugs = FinderSchema.schema_names.map { |schema_name| schema_name.singularize.camelize.constantize }
    current_format = document_slugs.detect { |model| model.slug == document_type_slug }
    authorize current_format
  end

  def get_csv_file_from_s3(filename)
    connection = Fog::Storage.new(
      provider: "AWS",
      region: ENV["AWS_REGION"],
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    )

    directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"])

    file = directory.files.get(filename)

    file.body
  end
end
