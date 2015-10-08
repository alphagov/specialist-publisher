Feature: Creating and editing an employment tribunal decision
  As an EmploymentTribunal editor
  I want to create air investigation report pages in Specialist publisher
  So that I can add them to the employment tribunal decisions finder

  Background:
    Given I am logged in as a "EmploymentTribunal" editor

  Scenario: Create a new employment tribunal decision
    When I create a employment tribunal decision
    Then the employment tribunal decision has been created
    And the employment tribunal decision should be in draft
    And the document should be sent to content preview

  Scenario: Cannot create a employment tribunal decision with invalid fields
    When I create a employment tribunal decision with invalid fields
    Then I should see error messages about missing fields
    Then I should see an error message about an invalid date field "Decision date"
    And I should see an error message about a "Body" field containing javascript
    And the employment tribunal decision should not have been created

  Scenario: Cannot edit an employment tribunal decision without entering required fields
    Given a draft employment tribunal decision exists
    When I edit an employment tribunal decision and remove required fields
    Then the employment tribunal decision should not have been updated

  Scenario: Can view a list of all employment tribunal decisions in the publisher
    Given two employment tribunal decisions exist
    Then the employment tribunal decisions should be in the publisher report index in the correct order

  Scenario: Edit a draft employment tribunal decision
    Given a draft employment tribunal decision exists
    When I edit a employment tribunal decision
    Then the employment tribunal decision should have been updated
    And the document should be sent to content preview
