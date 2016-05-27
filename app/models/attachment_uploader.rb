class AttachmentUploader
  def initialize(publisher: SpecialistPublisher)
    @publisher = publisher
  end

  def upload(attachment, document)
    attachment.url = file_url(attachment.file)
    add_attachment(document, attachment) unless attachment.changed?
    document.save!
    true
  rescue Document::RecordNotSaved => e
    Airbrake.notify(e)
    false
  end

private

  attr_reader :publisher

  def add_attachment(document, attachment)
    document.attachments ||= []
    document.attachments.push(attachment)
  end

  def file_url(file)
    response(file).file_url
  end

  def response(file)
    asset_api.create_asset(file: file)
  end

  def asset_api
    publisher.services(:asset_api)
  end
end
