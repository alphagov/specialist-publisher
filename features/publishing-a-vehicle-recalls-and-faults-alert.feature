Feature: Publishing Vehicle Recalls and Faults alerts
  As a DVSA Editor
  I want to publish Vehicle Recalls and Faults alerts
  So that they are available to the public

  Background:
  Given I am logged in as a "DVSA" editor

  Scenario: Creating a draft of a Vehicle Recalls and Faults alert
    When I create a Vehicle Recalls and Faults alert
    Then the Vehicle Recalls and Faults alert should be in draft

  Scenario: Publishing a draft of a Vehicle Recalls and Faults alert
    Given a draft of a Vehicle Recalls and Faults alert exists
    When I publish the Vehicle Recalls and Faults alert
    Then the Vehicle Recalls and Faults alert should be published

  Scenario: Creating and publishing a Vehicle Recalls and Faults alert
    When I publish a new Vehicle Recalls and Faults alert
    Then the Vehicle Recalls and Faults alert should be published
    And the publish should have been logged 1 times

  Scenario: Republishing a Vehicle Recalls and Faults alert
    When I publish a new Vehicle Recalls and Faults alert
    When I am on the Vehicle Recalls and Faults alert edit page
    And I edit the document and republish
    Then the amended document should be published
    And previous editions should be archived

  Scenario: Sending an email alert on first publish
    Given a draft of a Vehicle Recalls and Faults alert exists
    When I publish the Vehicle Recalls and Faults alert
    Then a publication notification should have been sent

  Scenario: Editing a published Vehicle Recalls and Faults alert
    Given a published Vehicle Recalls and Faults alert exists
    When I am on the Vehicle Recalls and Faults alert edit page
    And I edit the document without a change note
    Then I see an error requesting that I provide a change note

  Scenario: Making major updates
    Given a published Vehicle Recalls and Faults alert exists
    Then a publication notification should have been sent
    And the publish should have been logged 1 time
    When I am on the Vehicle Recalls and Faults alert edit page
    And I edit the document with a change note
    And I publish the Vehicle Recalls and Faults alert
    Then a publication notification should have been sent
    And the publish should have been logged 2 times

  Scenario: Making minor updates
    When I publish a new Vehicle Recalls and Faults alert
    Then the Vehicle Recalls and Faults alert should be published
    And the publish should have been logged 1 time
    And a publication notification should have been sent
    When I am on the Vehicle Recalls and Faults alert edit page
    And I edit the document and indicate the change is minor
    When I publish the Vehicle Recalls and Faults alert
    Then an email alert should not be sent
    And the publish should still have been logged 1 time
