module SpecialistDocumentsPathHelper

  def specialist_documents_path(type)
    url_for([type.to_sym])
  end

  def new_specialist_document_path(type)
    url_for([:new, type.singularize.to_sym])
  end

  def specialist_document_path(specialist_document)
    url_for([specialist_document])
  end

  def new_specialist_document_attachment_path(specialist_document)
    url_for([:new, specialist_document, :attachment])
  end

  def edit_specialist_document_attachment_path(specialist_document, attachment)
    url_for([:edit, specialist_document, attachment])
  end

  def preview_path_for_specialist_document(document)
    if document.persisted?
      url_for([:preview, document])
      # preview_cma_case_path(document)
    else
      url_for([:preview_new, document])
      # preview_new_cma_case_path
    end
  end

end
