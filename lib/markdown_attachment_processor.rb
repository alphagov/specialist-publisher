require "delegate"

class MarkdownAttachmentProcessor < SimpleDelegator

  def body
    attachments.reduce(doc.body) { |body, attachment|
      body.gsub(attachment.snippet) {
        attachment_markdown(attachment)
      }
    }
  end

  def attributes
    doc.attributes.merge(
      body: body,
    )
  end

private

  def attachment_markdown(attachment)
    "[#{attachment.title}](#{attachment.file_url})"
  end

  def doc
    __getobj__
  end

end
