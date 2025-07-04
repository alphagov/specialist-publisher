module ErrorsHelper
  def errors_for_input(errors, attribute)
    return nil if errors.blank?

    errors.filter_map { |error|
      if error.attribute == attribute
        error.full_message
      end
    }
    .join(tag.br)
    .html_safe
    .presence
  end

  def errors_for(errors, attribute)
    return nil if errors.blank?

    errors.filter_map { |error|
      if error.attribute == attribute
        {
          text: error.full_message,
        }
      end
    }
    .presence
  end

  def field_has_errors(document, field)
    field_errors(document, field).any?
  end

  def field_errors(document, field)
    if document.custom_error_message_fields.include?(field)
      document.errors.messages_for(field)
    else
      document.errors.full_messages_for(field)
    end
  end
end
