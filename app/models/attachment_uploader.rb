class AttachmentUploader
  def upload(attachment, document)
    if attachment.upload
      document.add_attachment(attachment) unless document.has_attachment?(attachment)
      document.save
    else
      false
    end
  end
end
