Feature: Publishing a manual
  As an editor
  I want to publish finished manuals
  So that they are available on GOV.UK

  Background:
    Given I am logged in as a "CMA" editor

  Scenario: Publish a manual
    Given a draft manual exists with some documents
    When I publish the manual
    Then the manual and all its documents are published
    And I should see a link to the live manual

  Scenario: Edit and re-publish a manual
    Given a published manual exists
    When I edit one of the manual's documents
    Then the updated manual document is available to preview
    When I publish the manual
    Then the manual and the edited document are published

  Scenario: Add a section to a published manual
    Given a published manual exists
    When I add another section to the manual
    And I publish the manual
    Then the manual and its new document are published

  Scenario: Add a change note
    Given a published manual exists
    When I create a new draft of a section with a change note
    And I re-publish the section

  Scenario: Omit the change note
    Given a published manual exists
    Then I see no visible change note in the manual document edit form
    When I edit one of the manual's documents without a change note
    Then I see an error requesting that I provide a change note
    When I indicate that the change is minor
    Then the document is updated without a change note

  Scenario: A manual fails to publish from the queue due to an unrecoverable error
    Given a draft manual exists without any documents
    And a draft document exists for the manual
    And an unrecoverable error occurs
    When I publish the manual
    Then the manual and its documents have failed to publish

  Scenario: A manual fails to publish from the queue due to a version mismatch
    Given a draft manual exists without any documents
    And a draft document exists for the manual
    And a version mismatch occurs
    When I publish the manual
    Then the manual and its documents have failed to publish

  @disable_background_processing
  Scenario: A manual has been queued to be published
    Given a draft manual exists without any documents
    And a draft document exists for the manual
    When I publish the manual
    Then the manual and its documents are queued for publishing

  Scenario: Manual publication retries after recoverable error
    Given a draft manual exists without any documents
    And a draft document exists for the manual
    And a recoverable error occurs
    When I publish the manual expecting a recoverable error
    Then the publication reattempted
