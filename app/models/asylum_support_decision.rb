require "document_metadata_decorator"

class AsylumSupportDecision < DocumentMetadataDecorator
  set_extra_field_names [
    :tribunal_decision_decision_date,
    :tribunal_decision_judges,
    :tribunal_decision_category,
    :tribunal_decision_sub_category,
    :tribunal_decision_landmark,
    :tribunal_decision_reference_number,
    :hidden_indexable_content
  ]
end
