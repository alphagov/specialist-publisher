class AttachmentPresenter
  def initialize(attachment)
    @attachment = attachment
  end

  def to_json(*_args)
    {
      attachment_type: "file",
      url: @attachment.url,
      title: @attachment.title,
      content_type: @attachment.content_type,
      updated_at:,
      created_at:,
      content_id: @attachment.content_id,
      id: @attachment.content_id,
    }
  end

private

  def updated_at
    if @attachment.updated_at.nil? || @attachment.being_updated == true
      @attachment.updated_at = Time.zone.now.rfc3339
    else
      @attachment.updated_at
    end
  end

  def created_at
    @attachment.created_at || Time.zone.now.rfc3339
  end
end
