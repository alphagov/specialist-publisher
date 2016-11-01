module PublishingHelper
  def handle_remote_error
    begin
      yield
      true
    rescue GdsApi::HTTPErrorResponse => e
      error_response_message(:base, e.message) if @publishable
      Airbrake.notify(e)
      false
    end
  end

  def set_errors_on(obj)
    unless obj.class.include?(ActiveModel::Validations)
      raise ArgumentError.new(
        "Can only set errors on an object which includes ActiveModel::Validations")
    end

    @publishable = obj
  end

  def error_response_message(key, message)
    if message.include? "conflicts with content_id"
      @publishable.errors.add(key, "Warning: This document's URL is already used on GOV.UK. You can't publish it until you change the title.")
    else
      @publishable.errors.add(:base, message)
    end
  end
end
