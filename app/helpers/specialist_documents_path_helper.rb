module SpecialistDocumentsPathHelper

  def specialist_documents_path(type)
    url_for([type.to_sym])
  end

end
