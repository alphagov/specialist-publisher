Feature: Creating and editing an asylum support decision
  As an AST editor
  I want to create air investigation report pages in Specialist publisher
  So that I can add them to the asylum support decisions finder

  Background:
    Given I am logged in as a "AST" editor

  Scenario: Create a new asylum support decision
    When I create a asylum support decision
    Then the asylum support decision has been created
    And the asylum support decision should be in draft
    And the document should be sent to content preview

  Scenario: Cannot create a asylum support decision with invalid fields
    When I create a asylum support decision with invalid fields
    Then I should see error messages about missing fields
    Then I should see an error message about an invalid date field "Decision date"
    And I should see an error message about a "Body" field containing javascript
    And the asylum support decision should not have been created

  Scenario: Cannot edit an asylum support decision without entering required fields
    Given a draft asylum support decision exists
    When I edit an asylum support decision and remove required fields
    Then the asylum support decision should not have been updated

  Scenario: Can view a list of all asylum support decisions in the publisher
    Given two asylum support decisions exist
    Then the asylum support decisions should be in the publisher report index in the correct order

  Scenario: Edit a draft asylum support decision
    Given a draft asylum support decision exists
    When I edit a asylum support decision
    Then the asylum support decision should have been updated
    And the document should be sent to content preview
