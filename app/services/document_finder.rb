class DocumentFinder
  def self.find(klass, content_id)
    begin
      response = Services.publishing_api.get_content(content_id)
    rescue GdsApi::HTTPNotFound
      raise RecordNotFound, "Document: #{content_id}"
    end

    attributes = response.to_hash
    document_type = attributes.fetch("document_type")
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
