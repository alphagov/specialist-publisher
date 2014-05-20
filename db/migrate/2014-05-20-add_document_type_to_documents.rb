module Migrations
  class AddDocumentTypeToDocuments
    def up
      SpecialistDocumentEdition
        .where(document_type: nil)
        .each do |document|
          document.update_attributes!(
            document_type: "cma_case",
          )
        end
    end
  end
end

require File.expand_path("../../../config/environment", __FILE__)

Migrations::AddDocumentTypeToDocuments.new.up
