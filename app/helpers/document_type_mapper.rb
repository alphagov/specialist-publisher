module DocumentTypeMapper
  def self.get_document_type(document_type)
    case document_type
    when "esi_fund"
      "european_structural_investment_fund"
    else
      document_type
    end
  end

  def self.all_document_types
    Rails.application.eager_load!
    Document.subclasses.tap { |a| a.delete(Attachment) }.map(&:downstream_document_type)
  end
end
