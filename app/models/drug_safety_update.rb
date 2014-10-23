require "document_metadata_decorator"

class DrugSafetyUpdate < DocumentMetadataDecorator
  set_extra_field_names [
    :therapeutic_area,
    :published_at,
  ]

  def publish!
    if document.extra_fields[:published_at].blank?
      document.update(
        extra_fields: extra_fields.merge(
          published_at: Time.now,
        ),
      )
    end
    document.publish!
  end

  def withdraw!
    document.update(
      extra_fields: extra_fields.merge(
        published_at: nil,
      )
    )
    document.withdraw!
  end

end
