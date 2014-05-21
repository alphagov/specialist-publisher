require "delegate"

class ManualWithDocuments < SimpleDelegator
  def initialize(manual, attrs)
    @manual = manual
    @documents = attrs.fetch(:documents)
    super(manual)
  end

  def documents
    @documents.to_enum
  end

  def add_document(document)
    @documents << document
  end

  def publish
    manual.publish do
      documents.each(&:publish)
    end
  end

  private
  attr_reader :manual
end
