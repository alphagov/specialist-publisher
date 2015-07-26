Feature: Creating and editing a Drug Safety Update
  As a MHRA Editor
  I want to create a drug safety update in Specialist publisher
  So that I can add them to the Drug Safety Update finder

  Background:
    Given I am logged in as a "MHRA" editor

  Scenario: Create a new Drug Safety Update
    When I create a Drug Safety Update
    Then the Drug Safety Update has been created
    And the document should be sent to content preview

  Scenario: Cannot create a Drug Safety Update with invalid fields
    When I create a Drug Safety Update with invalid fields
    Then I should see error messages about missing fields
    And I should see an error message about a "Body" field containing javascript
    And the Drug Safety Update should not have been created

  Scenario: Cannot edit a Drug Safety Update without entering required fields
    Given a draft Drug Safety Update exists
    When I edit a Drug Safety Update and remove required fields
    Then the Drug Safety Update should not have been updated

  Scenario: Can view a list of all Drug Safety Updates in the publisher
    Given two Drug Safety Updates exist
    Then the Drug Safety Updates should be in the publisher DSU index in the correct order

  Scenario: Edit a draft Drug Safety Update
    Given a draft Drug Safety Update exists
    When I edit a Drug Safety Update
    Then the Drug Safety Update should have been updated
    And the document should be sent to content preview
