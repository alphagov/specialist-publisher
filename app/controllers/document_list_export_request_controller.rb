class DocumentListExportRequestController < ApplicationController
  before_action :check_authorisation
  def show
    filename = "document_list_#{document_type_slug}_#{params[:export_id]}.csv"

    begin
      file = get_csv_file_from_s3(filename)
      send_data(file, filename:)
    rescue Aws::S3::Errors::NoSuchKey
      head :not_found
    end
  end

  def check_authorisation
    document_slugs = FinderSchema.schema_names.map { |schema_name| schema_name.singularize.camelize.constantize }
    current_format = document_slugs.detect { |model| model.slug == document_type_slug }
    authorize current_format
  end

  def get_csv_file_from_s3(filename)
    s3 = Aws::S3::Client.new

    obj = s3.get_object({
      bucket: ENV["AWS_S3_BUCKET_NAME"],
      key: filename,
    })

    obj.body.read
  end
end
