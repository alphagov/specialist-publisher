module Legacy::ErrorsHelper
  def field_has_errors(document, field)
    field_errors(document, field).any?
  end

  def field_errors(document, field)
    document.errors.full_messages_for(field)
  end
end
