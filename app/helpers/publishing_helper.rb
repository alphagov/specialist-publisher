module PublishingHelper
  def handle_remote_error(document)
    yield
    true
  rescue GdsApi::HTTPErrorResponse => e
    error_response_message(document, :base, e.message)
    GovukError.notify(e)
    false
  end

  def set_errors_on(document)
    unless document.class.include?(ActiveModel::Validations)
      raise ArgumentError.new(
        "Can only set errors on an object which includes ActiveModel::Validations",
      )
    end
  end

  def error_response_message(document, key, message)
    if message.include? "conflicts with content_id"
      document.errors.add(key, "Warning: This document's URL is already used on GOV.UK. You can't publish it until you change the title.")
    else
      document.errors.add(:base, message)
    end
  end
end
