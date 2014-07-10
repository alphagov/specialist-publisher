require "delegate"

class AttachmentSnippetInBodyValidator < SimpleDelegator
  def valid?
    document.valid? && document_body_has_govspeaked_attachments?
  end

  def errors
    document.errors.to_hash.merge(govspeaked_attachments_error)
  end

private
  def document
    __getobj__
  end

  def govspeaked_attachments_error
    document_body_has_govspeaked_attachments? ? {} : { attachments: error_message }
  end

  def error_message
    "are not referenced in the document body"
  end

  def document_body_has_govspeaked_attachments?
    document.attachments.all? { |a| document.body.include?(a.snippet) }
  end
end
