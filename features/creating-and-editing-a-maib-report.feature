Feature: Publishing an MAIB Report
  As an MAIB editor
  I want to create a new report in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a "MAIB" editor

  Scenario: Create a new MAIB report
    When I create a MAIB report
    Then the MAIB report has been created
    And the MAIB report should be in draft
    And the document should be sent to content preview

  Scenario: Cannot create a MAIB report with invalid fields
    When I create a MAIB report with invalid fields
    Then I should see error messages about missing fields
    Then I should see an error message about an invalid date field "Date of occurrence"
    And I should see an error message about a "Body" field containing javascript
    And the MAIB report should not have been created

  Scenario: Cannot edit an MAIB report without entering required fields
    Given a draft MAIB report exists
    When I edit an MAIB report and remove required fields
    Then the MAIB report should not have been updated

  Scenario: Can view a list of all MAIB reports in the publisher
    Given two MAIB reports exist
    Then the MAIB reports should be in the publisher report index in the correct order

  Scenario: Edit a draft MAIB report
    Given a draft MAIB report exists
    When I edit a MAIB report
    Then the MAIB report should have been updated
    And the document should be sent to content preview
