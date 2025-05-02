module Legacy::ErrorsHelper
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
