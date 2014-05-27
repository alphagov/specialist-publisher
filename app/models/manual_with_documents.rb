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

  def build_document(attributes)

    document_factory_factory(manual)

    document = SpecialistDocument.new(
      SlugGenerator.new(prefix: slug),
      SpecialistPublisherWiring.get(:edition_factory),
      SecureRandom.uuid,
      [],
    ).update( attributes.reverse_merge(
      document_type: "manual",
      opened_date: Date.parse('1/04/2014'),
      market_sector: 'manual',
      case_type: 'manual',
      case_state: 'manual',
    ))

    add_document(document)

    document
  end

  def publish
    manual.publish do
      documents.each(&:publish!)
    end
  end

  private
  attr_reader :manual

  def add_document(document)
    @documents << document
  end
end
