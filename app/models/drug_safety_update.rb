class DrugSafetyUpdate < Document
  FORMAT_SPECIFIC_FIELDS = [
    :therapeutic_area,
  ]

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def publish!
    indexable_document = SearchPresenter.new(self)

    handle_remote_error do
      update_type = self.update_type || 'major'

      Services.publishing_api.publish(content_id, update_type)
      Services.rummager.add_document(
        search_document_type,
        base_path,
        indexable_document.to_json,
      )
    end
  end

  def self.title
    "Drug Safety Update"
  end
end
