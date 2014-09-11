Feature: Creating and editing a manual
  As a CMA editor
  I want to create and edit a manual and see it in the publisher
  So that I can start moving my content to gov.uk

  Background:
    Given I am logged in as a "CMA" editor

  Scenario: Create a new manual
    When I create a manual
    Then the manual should exist

  Scenario: Edit a draft manual
    Given a draft manual exists
    When I edit a manual
    Then the manual should have been updated

  @javascript
  Scenario: Previewing a draft manual
    Given a draft manual exists
    When I make changes and preview the manual
    Then I see the manual body preview

  @javascript
  Scenario: Previewing a new manual
    When I start creating a new manual
    And I preview the manual
    Then I see the manual body preview

  @javascript
  Scenario: Previewing a manual with a body containing javascript
    When I start creating a new manual with embedded javascript
    And I preview the manual
    Then I should see an error message about a "Body" field containing javascript

  @regression
  Scenario: Create and edit a manual with documents
    Given a draft manual exists
    And a draft document exists for the manual
    When I edit a manual
    Then the manual's documents won't have changed

  Scenario: Try to create an invalid manual
    When I create a manual with an empty title
    Then I see errors for the title field

  Scenario: Try to create an invalid manual document
    Given a draft manual exists
    When I create a document with empty fields
    Then I see errors for the document fields

  Scenario: Add a document to a manual
    Given a draft manual exists
    When I create a document for the manual
    Then I see the manual has the new section

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

  Scenario: Duplicating a manual title
    Given a draft manual exists
    When I create another manual with the same slug
    Then I should see an error message about the duplicate slug

  Scenario: Duplicating a section title
    Given a draft manual exists
    And a draft document exists for the manual
    When I create a section with duplicate title
    Then I should see an error message about the duplicate slug

  @regression
  Scenario: Manual documents are not available as specialist documents
    Given a draft manual exists
    And a draft document exists for the manual
    When I visit the specialist documents path for the manual document
    Then the document is not found

  @javascript
  Scenario: Previewing a draft manual document with an attachment
    Given a draft manual exists
    And a draft document exists for the manual
    When I attach a file and give it a title
    Then I see the attached file
    When I copy+paste the embed code into the body of the document
    And I preview the document
    Then I can see a link to the file with the title in the document preview

  @javascript
  Scenario: Previewing a new manual document
    Given a draft manual exists
    When I create a document to preview
    And I preview the document
    Then I see the document body preview

  @javascript
  Scenario: Previewing a manual with invalid HTML
    Given a draft manual exists
    When I create a document to preview
    And I add invalid HTML to the document body
    And I preview the document
    Then I should see an error message about a "Body" field containing javascript
