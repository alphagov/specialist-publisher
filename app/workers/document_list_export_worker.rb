require 'csv'

class DocumentListExportWorker
  include Sidekiq::Worker

  def perform(document_type_slug, user_id, query)
    user = User.find(user_id)
    format = fetch_format(document_type_slug)
    authorize user, format
    csv = generate_csv(format, query)
    send_mail(csv, user, format, query)
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

  def send_mail(csv, user, format, query)
    NotificationsMailer.document_list(csv, user, format, query).deliver_now
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
end
