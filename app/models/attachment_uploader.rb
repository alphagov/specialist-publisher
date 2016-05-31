class AttachmentUploader
  def upload(attachment, document)
    if attachment.upload
      add_attachment(document, attachment) unless attachment.changed?
      document.save
    else
      false
    end
  end

private

  def add_attachment(document, attachment)
    document.attachments ||= []
    document.attachments.push(attachment)
  end
end
