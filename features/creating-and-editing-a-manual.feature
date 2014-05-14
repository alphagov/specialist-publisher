Feature: Creating and editing a manual
  As a CMA editor
  I want to create and edit a manual and see it in the publisher
  So that I can start moving my content to gov.uk

  Background:
    Given I am logged in as a CMA editor

  Scenario: Create a new manual
    When I create a manual
    Then the manual should exist

  Scenario: Edit a draft manual
    Given a draft manual exists
    When I edit a manual
    Then the manual should have been updated

  Scenario: Try to create an invalid manual
    When I create a manual with an empty title
    Then I see errors for the title field

  Scenario: Add a document to a manual
    Given a draft manual exists
    When I create a document for the manual
    Then I see the manual has the new page

  Scenario: Edit a draft document on a manual
    Given a draft manual exists
    And a draft document exists for the manual
    When I edit the document
    Then the document should have been updated

  Scenario: Attach a file to a manual document
    Given a draft manual exists
    And a draft document exists for the manual
    When I attach a file and give it a title
    Then I see the attached file

  Scenario: Manual documents are not available as specialist documents
    Given a draft manual exists
    And a draft document exists for the manual
    When I visit the specialist documents path for the manual document
    Then the document is not found
