require "document_metadata_decorator"

class EmploymentAppealTribunalDecision < DocumentMetadataDecorator
  set_extra_field_names [
    :hidden_indexable_content,
    :tribunal_decision_categories,
    :tribunal_decision_decision_date,
    :tribunal_decision_landmark,
    :tribunal_decision_sub_categories
  ]
end
