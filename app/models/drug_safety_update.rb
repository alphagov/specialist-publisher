require "document_metadata_decorator"

class DrugSafetyUpdate < DocumentMetadataDecorator
  set_extra_field_names [
    :therapeutic_area,
    :first_published_at,
  ]

  def publish!
    if document.extra_fields[:first_published_at].blank?
      document.update(
        extra_fields: extra_fields.merge(
          first_published_at: Time.now,
        ),
      )
    end
    document.publish!
  end

  def withdraw!
    document.update(
      extra_fields: extra_fields.merge(
        first_published_at: nil,
      )
    )
    document.withdraw!
  end

end
