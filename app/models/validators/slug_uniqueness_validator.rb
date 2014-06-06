require "delegate"

class SlugUniquenessValidator < SimpleDelegator
  def initialize(document_repository, document)
    @document_repository = document_repository
    @document = document
    @error_state = false
    super(@document)
  end

  def valid?
    document.valid? && slug_unique?
  end

  def errors
    document.errors.to_hash.merge(slug_error)
  end

  private

  attr_reader :document_repository, :document

  def slug_error
    slug_unique? ? {} : { slug: error_message }
  end

  def error_message
    "is already taken"
  end

  def slug_unique?
    document_repository.slug_unique?(document)
  end
end
