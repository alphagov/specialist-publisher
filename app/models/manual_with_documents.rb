require "delegate"

class ManualWithDocuments < SimpleDelegator
  def initialize(document_builder, manual, attrs)
    @manual = manual
    @documents = attrs.fetch(:documents)
    @document_builder = document_builder
    super(manual)
  end

  def documents
    @documents.to_enum
  end

  def build_document(attributes)
    document = document_builder.call(
      self,
      attributes
    )

    add_document(document)

    document
  end

  def publish
    manual.publish do
      documents.each(&:publish!)
    end
  end

  private
  attr_reader :document_builder, :manual

  def add_document(document)
    @documents << document
  end
end
