require "delegate"

class SpecialistDocumentAttachmentProcessor < SimpleDelegator

  def body
    doc.body.gsub(/\[InlineAttachment:(.+)\]/) do |a|
      attachment = find_attachment($1)
      "[#{attachment.title}](#{attachment.url})"
    end
  end

  private

  def find_attachment(filename)
    attachments.find { |a| a.filename == filename }
  end

  def doc
    __getobj__
  end

end
