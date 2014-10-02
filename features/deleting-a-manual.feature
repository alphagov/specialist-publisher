Feature: Script to delete a manual
  the `bin/delete_manual` script should delete a given manual and all its
  documents and its slug is no longer reserved

  Background:
    Given I am logged in as a "CMA" editor
    And a draft manual exists
    And a draft document exists for the manual

  Scenario: Deleting a manual
    When I run the deletion script
    And I confirm deletion
    Then the manual and its documents are deleted

  Scenario: Not confirming manual deletion
    When I run the deletion script
    And I refuse deletion
    Then the manual and its documents still exist
