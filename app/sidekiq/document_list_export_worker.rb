require "csv"
require "date"
require "securerandom"

class DocumentListExportWorker
  include Sidekiq::Job

  def perform(document_type_slug, user_id, query)
    user = User.find(user_id)
    format = fetch_format(document_type_slug)
    authorize user, format
    csv = generate_csv(format, query)

    export_id = SecureRandom.uuid
    filename = "document_list_#{document_type_slug}_#{export_id}.csv"
    public_url = Plek.find("specialist-publisher", external: true) + "/export/#{document_type_slug}/#{export_id}"

    upload_csv(filename, csv)

    send_mail(public_url, user, format, query)
  end

private

  def authorize(user, format)
    policy = DocumentPolicy.new(user, format)
    raise Pundit::NotAuthorizedError, query: :index?, record: format, policy: policy unless policy.index?
  end

  def fetch_format(document_type_slug)
    document_models.detect { |model| model.admin_slug == document_type_slug }
  end

  def document_models
    FinderSchema.schema_names.map do |schema_name|
      schema_name.singularize.camelize.constantize
    end
  end

  def send_mail(url, user, format, query)
    NotificationsMailer.document_list(url, user, format, query).deliver_now
  end

  def generate_csv(format, query)
    exporter = DocumentExportPresenter.new(format)
    CSV.generate do |csv|
      csv << exporter.header_row
      AllDocumentsFinder.find_each(format, query:) do |edition|
        csv << exporter.parse_document(edition)
      end
    end
  end

  def upload_csv(filename, csv)
    S3FileUploader.save_file_to_s3(filename, csv)
  end
end
