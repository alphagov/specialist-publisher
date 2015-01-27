require "formatters/abstract_artefact_formatter"

class CountrysideStewardshipGrantArtefactFormatter < AbstractArtefactFormatter

  def state
    state_mapping.fetch(entity.publication_state)
  end

  def kind
    "countryside_stewardship_grants"
  end

  def rendering_app
    "specialist-frontend"
  end

  def organisation_slugs
    %w(
      natural-england
      department-for-environment-food-rural-affairs
      forestry-commission
    )
  end
end
