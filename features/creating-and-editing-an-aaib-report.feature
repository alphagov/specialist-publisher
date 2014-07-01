Feature: Creating and editing an AAIB Report
  As an AAIB editor
  I want to create air investigation report pages in Specialist publisher
  So that I can add them to the AAIB reports finder

  Background:
    Given I am logged in as a "AAIB" editor

  Scenario: Create a new AAIB report
    When I create a AAIB report
    Then the AAIB report has been created

  Scenario: Cannot create a AAIB report without entering required fields
    When I create a AAIB report without one of the required fields
    Then I should see an error message about a missing field
    Then I should see an error message about an invalid date field "Date of occurrence"
    And the AAIB report should not have been created

  Scenario: Can view a list of all AAIB reports in the publisher
    Given two AAIB reports exist
    Then the AAIB reports should be in the publisher report index in the correct order

  Scenario: Edit a draft AAIB report
    Given a draft AAIB report exists
    When I edit a AAIB report
    Then the AAIB report should have been updated
