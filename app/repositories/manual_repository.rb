class ManualRepository
  def store(manual)
    create_manual_edition(manual)
  end

  def fetch(manual_id)
    edition = ManualEdition.where(manual_id: manual_id).last
    build_manual_for(edition)
  end

private
  def create_manual_edition(manual)
    ManualEdition.create(attributes_for(manual))
  end

  def attributes_for(manual)
    {
      manual_id: manual.id,
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
