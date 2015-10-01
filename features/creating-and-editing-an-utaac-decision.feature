Feature: Creating and editing an UTAAC decision
  As an UTAAC editor
  I want to create air investigation report pages in Specialist publisher
  So that I can add them to the UTAAC decisions finder

  Background:
    Given I am logged in as a "UTAAC" editor

  Scenario: Create a new UTAAC decision
    When I create a UTAAC decision
    Then the UTAAC decision has been created
    And the UTAAC decision should be in draft
    And the document should be sent to content preview

  Scenario: Cannot create a UTAAC decision with invalid fields
    When I create a UTAAC decision with invalid fields
    Then I should see error messages about missing fields
    Then I should see an error message about an invalid date field "Decision date"
    And I should see an error message about a "Body" field containing javascript
    And the UTAAC decision should not have been created

  Scenario: Cannot edit an UTAAC decision without entering required fields
    Given a draft UTAAC decision exists
    When I edit an UTAAC decision and remove required fields
    Then the UTAAC decision should not have been updated

  Scenario: Can view a list of all UTAAC decisions in the publisher
    Given two UTAAC decisions exist
    Then the UTAAC decisions should be in the publisher report index in the correct order

  Scenario: Edit a draft UTAAC decision
    Given a draft UTAAC decision exists
    When I edit a UTAAC decision
    Then the UTAAC decision should have been updated
    And the document should be sent to content preview
