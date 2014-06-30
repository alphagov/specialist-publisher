require "document_metadata_decorator"

class CmaCase < DocumentMetadataDecorator
  set_extra_field_names [
    :opened_date,
    :closed_date,
    :case_type,
    :case_state,
    :market_sector,
    :outcome_type,
  ]
end
