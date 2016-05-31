class AttachmentUploader
  def upload(attachment, document)
    if attachment.upload
      document.add_attachment(attachment) unless attachment.changed?
      document.save
    else
      false
    end
  end
end
