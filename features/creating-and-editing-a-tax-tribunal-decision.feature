Feature: Creating and editing a tax tribunal decision
  As an TaxTribunal editor
  I want to create air investigation report pages in Specialist publisher
  So that I can add them to the tax tribunal decisions finder

  Background:
    Given I am logged in as a "TaxTribunal" editor

  Scenario: Create a new tax tribunal decision
    When I create a tax tribunal decision
    Then the tax tribunal decision has been created
    And the tax tribunal decision should be in draft
    And the document should be sent to content preview

  Scenario: Cannot create a tax tribunal decision with invalid fields
    When I create a tax tribunal decision with invalid fields
    Then I should see error messages about missing fields
    Then I should see an error message about an invalid date field "Release date"
    And I should see an error message about a "Body" field containing javascript
    And the tax tribunal decision should not have been created

  Scenario: Cannot edit a tax tribunal decision without entering required fields
    Given a draft tax tribunal decision exists
    When I edit a tax tribunal decision and remove required fields
    Then the tax tribunal decision should not have been updated

  Scenario: Can view a list of all tax tribunal decisions in the publisher
    Given two tax tribunal decisions exist
    Then the tax tribunal decisions should be in the publisher report index in the correct order

  Scenario: Edit a draft tax tribunal decision
    Given a draft tax tribunal decision exists
    When I edit a tax tribunal decision
    Then the tax tribunal decision should have been updated
    And the document should be sent to content preview
