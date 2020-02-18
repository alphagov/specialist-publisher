class DocumentListExportRequest
  include Mongoid::Document
  field :filename, type: String
  field :document_class, type: String
  field :query, type: String
  field :notification_email, type: String
  field :generated_at, type: Time

  def ready?
    generated_at.present?
  end

  def public_url
    Plek.find("specialist-publisher", external: true) + "/export/#{id}"
  end
end
