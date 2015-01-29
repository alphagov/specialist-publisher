require "document_metadata_decorator"

class CountrysideStewardshipGrant < DocumentMetadataDecorator
  set_extra_field_names [
    :grant_type,
    :land_use,
    :tiers_or_standalone_items,
    :funding_amount,
  ]
end
