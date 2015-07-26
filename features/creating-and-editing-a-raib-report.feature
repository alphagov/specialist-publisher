Feature: Publishing a RAIB Report
  As an RAIB editor
  I want to create a new report in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a "RAIB" editor

  Scenario: Create a new RAIB report
    When I create a RAIB report
    Then the RAIB report has been created
    And the RAIB report should be in draft
    And the document should be sent to content preview

  Scenario: Cannot create a RAIB report with invalid fields
    When I create a RAIB report with invalid fields
    Then I should see error messages about missing fields
    Then I should see an error message about an invalid date field "Date of occurrence"
    And I should see an error message about a "Body" field containing javascript
    And the RAIB report should not have been created

  Scenario: Cannot edit an RAIB report without entering required fields
    Given a draft RAIB report exists
    When I edit an RAIB report and remove required fields
    Then the RAIB report should not have been updated

  Scenario: Can view a list of all RAIB reports in the publisher
    Given two RAIB reports exist
    Then the RAIB reports should be in the publisher report index in the correct order

  Scenario: Edit a draft RAIB report
    Given a draft RAIB report exists
    When I edit a RAIB report
    Then the RAIB report should have been updated
    And the document should be sent to content preview
