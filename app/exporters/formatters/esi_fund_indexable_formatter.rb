require "formatters/abstract_specialist_document_indexable_formatter"

class EsiFundIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter

  def type
    "european_structural_investment_fund"
  end

private
  def organisation_slugs
    []
  end
end
