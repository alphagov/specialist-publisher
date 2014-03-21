Feature: Script to rerender published documents
  the `bin/rerender_published_documents` script should regenerate the
  RenderedSpecialistDocument for every published edition

  Scenario: Rerender all published documents
    Given some published and draft specialist documents exist
    And their RenderedSpecialistDocument records are missing
    When I run the "bin/rerender_published_documents" script
    Then the RenderedSpecialistDocument records of published documents should be regenerated
