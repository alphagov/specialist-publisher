Feature: Script to delete a manual
  the `bin/delete_draft_manual` script should delete a given manual and all its
  documents and its slug is no longer reserved

  Background:
    Given I am logged in as a "CMA" editor

  Scenario: Deleting a manual
    Given a draft manual exists without any documents
    And a draft document exists for the manual
    When I run the deletion script
    And I confirm deletion
    Then the manual and its documents are deleted

  Scenario: Not confirming manual deletion
    Given a draft manual exists without any documents
    And a draft document exists for the manual
    When I run the deletion script
    And I refuse deletion
    Then the manual and its documents still exist

  Scenario: Deleting a published manual
    Given a published manual exists
    When I run the deletion script
    Then the script raises an error
    And the manual and its documents still exist
