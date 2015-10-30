Feature: Creating and editing an employment appeal tribunal decision
  As an EmploymentAppealTribunal editor
  I want to create air investigation report pages in Specialist publisher
  So that I can add them to the employment appeal tribunal decisions finder

  Background:
    Given I am logged in as a "EmploymentAppealTribunal" editor

  Scenario: Create a new employment appeal tribunal decision
    When I create a employment appeal tribunal decision
    Then the employment appeal tribunal decision has been created
    And the employment appeal tribunal decision should be in draft
    And the document should be sent to content preview

  Scenario: Cannot create a employment appeal tribunal decision with invalid fields
    When I create a employment appeal tribunal decision with invalid fields
    Then I should see error messages about missing fields
    Then I should see an error message about an invalid date field "Decision date"
    And I should see an error message about a "Body" field containing javascript
    And the employment appeal tribunal decision should not have been created

  Scenario: Cannot edit an employment appeal tribunal decision without entering required fields
    Given a draft employment appeal tribunal decision exists
    When I edit an employment appeal tribunal decision and remove required fields
    Then the employment appeal tribunal decision should not have been updated

  Scenario: Can view a list of all employment appeal tribunal decisions in the publisher
    Given two employment appeal tribunal decisions exist
    Then the employment appeal tribunal decisions should be in the publisher report index in the correct order

  Scenario: Edit a draft employment appeal tribunal decision
    Given a draft employment appeal tribunal decision exists
    When I edit a employment appeal tribunal decision
    Then the employment appeal tribunal decision should have been updated
    And the document should be sent to content preview
