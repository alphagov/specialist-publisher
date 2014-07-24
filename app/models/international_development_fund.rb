require "document_metadata_decorator"

class InternationalDevelopmentFund < DocumentMetadataDecorator
  set_extra_field_names [
    :application_state,
    :location,
    :development_sector,
    :eligible_entities,
    :value_of_fund,
  ]
end
