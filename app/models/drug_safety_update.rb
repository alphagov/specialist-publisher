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

    begin
      update_type = self.update_type || 'major'
      publish_request = publishing_api.publish(content_id, update_type)
      rummager_request = rummager.add_document(
        search_document_type,
        base_path,
        indexable_document.to_json,
      )

      publish_request.code == 200 && rummager_request.code == 200

    rescue GdsApi::HTTPErrorResponse => e
      Airbrake.notify(e)
    end
  end

  def self.publishing_api_document_type
    "drug_safety_update"
  end

  def self.title
    "Drug Safety Update"
  end
end
