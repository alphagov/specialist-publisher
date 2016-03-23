class AttachmentPresenter

  def initialize(attachment)
    @attachment = attachment
  end

  def to_json
    {
      url: @attachment.url,
      title: @attachment.title,
      content_type: @attachment.content_type,
      updated_at: updated_at,
      created_at: created_at,
      content_id: @attachment.content_id
    }
  end

private
  def updated_at
    Time.now.to_datetime.rfc3339
  end

  def created_at
    @attachment.created_at || Time.now.to_datetime.rfc3339
  end
end
