require "csv"
require "date"

class DocumentListExportWorker
  include Sidekiq::Worker

  def perform(document_type_slug, user_id, query)
    user = User.find(user_id)
    format = fetch_format(document_type_slug)
    authorize user, format
    csv = generate_csv(format, query)
    filename = "document_list_#{user_id}_#{DateTime.now.xmlschema}.csv"
    url = upload_csv(filename, csv)
    send_mail(url, user, format, query)
  end

private

  def authorize(user, format)
    policy = DocumentPolicy.new(user, format)
    raise Pundit::NotAuthorizedError, query: :index?, record: format, policy: policy unless policy.index?
  end

  def fetch_format(document_type_slug)
    document_models.detect { |model| model.slug == document_type_slug }
  end

  def document_models
    FinderSchema.schema_names.map do |schema_name|
      schema_name.singularize.camelize.constantize
    end
  end

  def send_mail(url, user, format, query)
    NotificationsMailer.document_list(url, user, format, query).deliver_now
  end

  def fetch_exporter(format)
    DocumentExportPresenter.for(format)
  end

  def generate_csv(format, query)
    exporter = fetch_exporter(format)
    CSV.generate do |csv|
      csv << exporter.header_row
      AllDocumentsFinder.find_each(format, query: query) do |edition|
        presenter = exporter.new(edition)
        csv << presenter.row
      end
    end
  end

  def upload_csv(filename, csv)
    s3_file = S3FileUploader.save_file_to_s3(filename, csv)
    s3_file.public_url
  end
end
