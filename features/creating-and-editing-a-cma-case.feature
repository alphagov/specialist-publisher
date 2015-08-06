Feature: Creating and editing a CMA case
  As a CMA editor
  I want to create and edit a case and see it in the publisher
  So that I can start moving my content to gov.uk

  Background:
    Given I am logged in as a "CMA" editor

  Scenario: Create a new CMA case
    When I create a CMA case
    Then the CMA case has been created
    And the document should be sent to content preview
    And I should see a link to preview the document

  Scenario: Cannot create a CMA case with invalid fields
    When I create a CMA case with invalid fields
    Then I should see error messages about missing fields
    And I should see an error message about an invalid date field "Opened date"
    And I should see an error message about a "Body" field containing javascript
    And the CMA case should not have been created

  Scenario: Create a CMA case with a clashing slug
    Given a published CMA case exists
    When I create another case with the same slug
    Then I see a warning about slug clash at publication

  Scenario: Can view a list of all cases in the publisher
    Given two CMA cases exist
    Then the CMA cases should be in the publisher case index in the correct order

  Scenario: Edit a draft CMA case
    Given a draft CMA case exists
    When I edit a CMA case
    Then the CMA case should have been updated
    And the document should be sent to content preview

  Scenario: Change the title of a previously published document
    Given a published CMA case exists
    When I change the CMA case title and re-publish
    Then the title has been updated
    And the URL slug remains unchanged

  @javascript
  Scenario: Previewing a draft CMA case
    Given a draft CMA case exists
    When I make changes and preview the CMA case
    Then I see the case body preview

  @javascript
  Scenario: Previewing a new CMA case
    When I start creating a new CMA case
    And I preview the case
    Then I see the case body preview

  @javascript
  Scenario: Previewing a CMA case with a body containing javascript
    When I start creating a new CMA case with embedded javascript
    And I preview the case
    Then I should see an error message about a "Body" field containing javascript
