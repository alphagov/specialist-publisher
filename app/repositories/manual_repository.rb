class ManualRepository
  def initialize(dependencies = {})
    @collection = dependencies.fetch(:collection) { ManualRecord }
    @factory = dependencies.fetch(:factory) { Manual.method(:new) }
  end

  def store(manual)
    manual_record = collection.find_or_initialize_by(manual_id: manual.id)
    edition = manual_record.new_or_existing_draft_edition
    edition.attributes = attributes_for(manual)

    manual_record.save!
  end

  def fetch(manual_id)
    manual_record = collection.find_by(manual_id: manual_id)
    build_manual_for(manual_record)
  end

  def all
    collection.all.lazy.map { |manual_record|
      build_manual_for(manual_record)
    }
  end

private
  attr_reader :collection, :factory

  def attributes_for(manual)
    {
      title: manual.title,
      summary: manual.summary,
    }
  end

  def build_manual_for(record)
    edition = record.latest_edition

    factory.call(
      id: record.manual_id,
      title: edition.title,
      summary: edition.summary,
      updated_at: edition.updated_at,
    )
  end
end
