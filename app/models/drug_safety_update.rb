class DrugSafetyUpdate < Document
  FORMAT_SPECIFIC_FIELDS = [
    :therapeutic_area,
    :first_published_at,
  ]

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def publish!
    indexable_document = SearchPresenter.new(self)

    handle_remote_error do
      update_type = self.update_type || 'major'

      save_first_published_at if not_published?

      Services.publishing_api.publish(content_id, update_type)
      Services.rummager.add_document(
        search_document_type,
        base_path,
        indexable_document.to_json,
      )
    end
  end

  def self.publishing_api_document_type
    "drug_safety_update"
  end

  def self.title
    "Drug Safety Update"
  end

private

  def save_first_published_at
    self.first_published_at = Time.zone.now
    presented_document = DocumentPresenter.new(self).to_json

    Services.publishing_api.put_content(self.content_id, presented_document)
  end
end
