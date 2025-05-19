module DocumentTypeMapper
  def self.get_document_type(document_type)
    case document_type
    when "esi_fund"
      "european_structural_investment_fund"
    else
      document_type
    end
  end
end
