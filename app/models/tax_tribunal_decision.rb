require "document_metadata_decorator"

class TaxTribunalDecision < DocumentMetadataDecorator
  set_extra_field_names [
    :hidden_indexable_content,
    :tribunal_decision_category,
    :tribunal_decision_decision_date,
  ]
end
