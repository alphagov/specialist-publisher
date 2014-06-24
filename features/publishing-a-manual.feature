Feature: Publishing a manual
  As an editor
  I want to publish finished manuals
  So that they are availale on gov.uk

  Background:
    Given I am logged in as a "CMA" editor

  Scenario: Publish a manual
    Given a draft manual exists
    And a draft document exists for the manual
    When I publish the manual
    Then the manual and its documents are published

  Scenario: Edit and re-publish a manual
    Given a published manual exists
    When I edit the manual's documents
    And I publish the manual
    Then the manual and its documents are published

  Scenario: Add a section to a published manual
    Given a published manual exists
    When I add another section to the manual
    And I publish the manual
    Then the manual and its documents are published

  Scenario: Add a change note
    Given a published manual exists
    When I create a new draft of a section with a change note
    And I re-publish the section
    Then the change note is also published

  Scenario: Omit the change note
    Given a published manual exists
    When I edit the document without a change note
    Then I see an error requesting that I provide a change note
    When I indicate that the change is minor
    Then the document is updated without a change note
