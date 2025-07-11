module ErrorsHelper
  def errors_for_input(object_type, errors, attribute)
    return nil if errors.blank?

    errors.filter_map { |error|
      if error.attribute == attribute
        get_text(object_type, error)
      end
    }
    .join(tag.br)
    .html_safe
    .presence
  end

  def errors_for(object_type, errors, attribute)
    return nil if errors.blank?

    errors.filter_map { |error|
      if error.attribute == attribute
        {
          text: get_text(object_type, error),
        }
      end
    }
    .presence
  end

  def get_text(object_type, error)
    return error.full_message unless object_type

    custom_error = I18n.exists?("activemodel.errors.models.#{object_type}.attributes.#{error.attribute}", :en)
    custom_error ? error.message : error.full_message
  end
end
