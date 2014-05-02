class ManualRepository
  def store(manual)
    create_or_update_manual_edition(manual)
  end

  def fetch(manual_id)
    edition = ManualEdition.where(manual_id: manual_id).last
    build_manual_for(edition)
  end

  def all
    ManualEdition.all.map do |edition|
      build_manual_for(edition)
    end
  end

private
  def create_or_update_manual_edition(manual)
    edition = ManualEdition.find_or_initialize_by(manual_id: manual.id, state: 'draft')
    edition.update_attributes(attributes_for(manual))
  end

  def attributes_for(manual)
    {
      title: manual.title,
      summary: manual.summary,
    }
  end

  def build_manual_for(manual_edition)
    Manual.new(
      id: manual_edition.manual_id,
      title: manual_edition.title,
      summary: manual_edition.summary,
    )
  end
end
