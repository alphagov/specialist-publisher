require "services"

# Find a document of a certain type by content_id. Returns a `Document` object.
class DocumentFinder
  include DocumentTypeMapper

  def self.find(klass, content_id, locale, version: nil)
    begin
      params = { locale: }
      params.merge!(version:) if version

      response = Services.publishing_api.get_content(content_id, params)
    rescue GdsApi::HTTPNotFound
      raise RecordNotFound, "Document: #{content_id}"
    end

    attributes = response.to_hash
    document_type = DocumentTypeMapper.get_document_type(attributes.fetch("document_type"))
    document_class = document_type.camelize.constantize

    if [document_class, Document].include?(klass)
      document_class.from_publishing_api(response.to_hash)
    else
      message = "#{self}.find('#{content_id}') returned the wrong type: '#{document_class}'"
      raise TypeMismatchError, message
    end
  end

  class RecordNotFound < StandardError; end

  class TypeMismatchError < StandardError; end
end
