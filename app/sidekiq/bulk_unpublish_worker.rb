class BulkUnpublishWorker
  include Sidekiq::Job

  class InvalidCsvError < StandardError; end

  def perform(document_type_slug, user_id, csv_input)
    user = User.find(user_id)
    raise Pundit::NotAuthorizedError, "User is not a GDS editor" unless user.gds_editor?

    format = fetch_format(document_type_slug)

    unpublisher = BulkDocumentUnpublisher.new(format, csv_input)
    unpublisher.validate

    raise InvalidCsvError, unpublisher.errors.join(", ") unless unpublisher.valid?

    total = unpublisher.rows.count
    failures = unpublisher.call

    log_result(format, total, failures)
  end

private

  def fetch_format(document_type_slug)
    FinderSchema.document_models.detect { |model| model.admin_slug == document_type_slug } ||
      raise(ArgumentError, "Unknown document type: #{document_type_slug}")
  end

  def log_result(format, total, failures)
    Rails.logger.info("Bulk unpublished #{total - failures.count} of #{total} #{format.title.pluralize}")

    Rails.logger.error("Bulk unpublishing failed for: #{failures.join(', ')}") if failures.any?
  end
end
