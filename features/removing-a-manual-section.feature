Feature: Script to remove a draft manual section
  As a DevOps specialist
  I want to remove a draft section from a manual
  So that it no longer one of the manual's sections

  Scenario: Removing a draft section
    Given a draft manual was created without the UI
    Given a draft section was created for the manual without the UI
    When I run the manual section removal script
    And I confirm removal
    Then the manual section is removed

  Scenario: Not confirming removal
    Given a draft manual was created without the UI
    Given a draft section was created for the manual without the UI
    When I run the manual section removal script
    And I refuse removal
    Then the manual section still exists

  # Can't really cover a published section scenario due to the way user
  # confirmation and the services are handled, but this should already be
  # covered in the specs for the other participating objects.
