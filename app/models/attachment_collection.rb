class AttachmentCollection
  include Enumerable

  def initialize(attachments = [])
    @attachments = attachments
  end

  def find(content_id)
    @attachments.detect { |attachment| attachment.content_id == content_id }
  end

  def build(params)
    new_attachment = Attachment.new(params)
    @attachments << new_attachment
    new_attachment
  end

  def upload(attachment)
    attachment.upload if has_attachment?(attachment)
  end

  def update(attachment)
    attachment.update if has_attachment?(attachment)
  end

  def has_attachment?(attachment)
    !!find(attachment.content_id)
  end

  def each(&block)
    @attachments.each do |attachment|
      block.call(attachment)
    end
  end
end
