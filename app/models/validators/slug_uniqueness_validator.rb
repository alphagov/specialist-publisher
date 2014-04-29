require "delegate"

class SlugUniquenessValidator < SimpleDelegator
  def initialize(document_repository, document)
    @document_repository = document_repository
    @document = document
    @error_state = false
    super(@document)
  end

  def valid?
    unset_error_state
    if document_with_same_slug_exists?
      set_error_state
    end

    errors.empty?
  end

  def errors
    if error_state?
      document.errors.merge(slug_error)
    else
      document.errors
    end
  end

  private

  attr_reader :document_repository, :document

  def error_state?
    @error_state
  end

  def unset_error_state
    @error_state = false
  end

  def set_error_state
    @error_state = true
  end

  def slug_error
    { slug: error_message }
  end

  def error_message
    "is already taken"
  end

  def document_with_same_slug_exists?
    !document_repository.slug_unique?(document)
  end
end
