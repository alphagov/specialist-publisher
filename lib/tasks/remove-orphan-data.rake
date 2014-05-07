namespace :db do
  desc 'Delete PanopticonMapping records without corresponding SpecialistDocumentEditions and vice-versa'
  task :remove_orphan_data => :environment do
    delete_specialist_editions_without_mappings
    delete_mappings_with_non_existant_documents
  end

  def delete_specialist_editions_without_mappings
    SpecialistDocumentEdition.not_in(document_id: document_ids_with_mappings).each do |edition|
      puts "Deleting #{edition.inspect}"
      edition.delete
    end
  end

  def delete_mappings_with_non_existant_documents
    PanopticonMapping.not_in(document_id: document_ids_with_editions).each do |mapping|
      puts "Deleting #{mapping.inspect}"
      mapping.delete
    end
  end

  def document_ids_with_mappings
    PanopticonMapping.all.distinct(:document_id)
  end

  def document_ids_with_editions
    SpecialistDocumentEdition.all.distinct(:document_id)
  end
end
