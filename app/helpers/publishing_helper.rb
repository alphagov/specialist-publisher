module PublishingHelper
  def handle_remote_error(&block)
    begin
      block.call
      true
    rescue GdsApi::HTTPErrorResponse => e
      Airbrake.notify(e)
      false
    end
  end
end
