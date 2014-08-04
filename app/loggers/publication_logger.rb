class PublicationLogger

  def initialize(manual, state)
    @manual = manual
    @state = state
  end

  def call
    manual.documents.each do |doc|
      PublicationLog.create!(
        title: doc.title,
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
