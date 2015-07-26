Feature: Creating and editing a Vehicle Recalls and Faults alert
  As a DVSA Editor
  I want to create Vehicle Recalls and Faults alert pages in Specialist publisher
  So that I can add them to the Vehicle Recalls and Faults alert finder

  Background:
    Given I am logged in as a "DVSA" editor

  Scenario: Creating a new Vehicle Recalls and Faults alert
    When I create a Vehicle Recalls and Faults alert
    Then I should see that Vehicle Recalls and Faults alert
    And the document should be sent to content preview

  Scenario: Providing invalid inputs when creating an alert
    When I try to save a Vehicle Recall alert with invalid HTML and no title
    Then I should see error messages about missing fields
    And I should see an error message about invalid HTML in "Body"
    And I should see an error message about an invalid date field "Alert issue date"
    And the Vehicle Recall alert is not persisted

  Scenario: Providing invalid inputs when editing an alert
    Given a draft of a Vehicle Recalls and Faults alert exists
    When I edit the Vehicle Recalls and Faults alert and remove summary
    Then the Vehicle Recalls and Faults alert should show an error for the summary

  Scenario: Viewing a list of all Vehicle Recalls and Faults alerts in the publisher
    Given two Vehicle Recalls and Faults alerts exist
    Then the Vehicle Recalls and Faults alerts should be in the publisher CSG index

  Scenario: Editing a draft Vehicle Recalls and Faults alert
    Given a draft of a Vehicle Recalls and Faults alert exists
    When I change the title of that Vehicle Recalls and Faults alert to "A big vehicle fault"
    Then I should see "A big vehicle fault" as the title fo the Vehicle Recalls and Faults alert
    And the document should be sent to content preview
