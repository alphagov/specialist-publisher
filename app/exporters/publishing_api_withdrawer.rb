class PublishingAPIWithdrawer
  def initialize(publishing_api:, entity:)
    @publishing_api = publishing_api
    @entity = entity
  end

  def call
    publishing_api.put_content_item(base_path, exportable_attributes)
  end

private

  attr_reader(
    :publishing_api,
    :entity,
  )

  def base_path
    "/#{entity.slug}"
  end

  def exportable_attributes
    {
      format: "gone",
      publishing_app: "specialist-publisher",
      update_type: "major",
      routes: [
        {
          path: base_path,
          type: "exact",
        }
      ],
    }
  end
end
