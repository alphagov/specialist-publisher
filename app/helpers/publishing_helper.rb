module PublishingHelper
  def handle_remote_error(&block)
    begin
      block.call
      true
    rescue GdsApi::HTTPErrorResponse => e
      @publishable.errors.add(:base, e.message) if @publishable
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
end
