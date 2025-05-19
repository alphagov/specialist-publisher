module DocumentTypeMapper
  OUTLIER_DOCUMENT_TYPES = {
    "esi_fund" => "european_structural_investment_fund",
  }.freeze

  def self.get_document_type(document_type)
    OUTLIER_DOCUMENT_TYPES[document_type] || document_type
  end
end
