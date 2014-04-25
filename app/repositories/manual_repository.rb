class ManualRepository
  def store(manual)
    create_manual_edition(manual)
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
end
