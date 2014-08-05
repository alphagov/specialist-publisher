class PublicationLogger

  def initialize(manual, state)
    @manual = manual
    @state = state
  end

  def call
    manual.documents.each do |doc|
      PublicationLog.create!(
        title: doc.title,
        manual_version_number: manual.version_number,
        version_number: doc.version_number,
        slug: doc.slug,
        change_note: doc.change_note,
        document_state: state,
      )
    end
  end

private

  attr_reader(
    :manual,
    :state,
  )

end
