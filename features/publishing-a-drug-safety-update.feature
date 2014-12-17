Feature: Publishing an Drug Safety Update
  As a MHRA Editor
  I want to create a drug safety update in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a "MHRA" editor

  Scenario: can create a new Drug Safety Update in draft
    When I create a Drug Safety Update
    Then the Drug Safety Update should be in draft

  Scenario: can publish a draft Drug Safety Update
    Given a draft Drug Safety Update exists
    When I publish the Drug Safety Update
    Then the Drug Safety Update should be published

  Scenario: can create a new Drug Safety Update and publish immediately
    When I publish a new Drug Safety Update
    Then the Drug Safety Update should be published
    And the publish should have been logged 1 times

  Scenario: immediately republish a published Drug Safety Update
    When I publish a new Drug Safety Update
    When I am on the Drug Safety Update edit page
    And I edit the document and republish
    Then the amended document should be published
    And previous editions should be archived

  Scenario: Sends an email alert on first publish
    Given a draft Drug Safety Update exists
    When I publish the Drug Safety Update
    Then a publication notification should not have been sent

  Scenario: Cannot edit a published Drug Safety Update without a change note
    Given a published Drug Safety Update exists
    When I am on the Drug Safety Update edit page
    And I edit the document without a change note
    Then I see an error requesting that I provide a change note

  Scenario: Sends an email alert on a major update and updates logs
    Given a published Drug Safety Update exists
    Then a publication notification should not have been sent
    And the publish should have been logged 1 time
    When I am on the Drug Safety Update edit page
    And I edit the document with a change note
    And I publish the Drug Safety Update
    Then a publication notification should not have been sent
    And the publish should have been logged 2 times

  Scenario: Minor updates do not send emails or update logs
    When I publish a new Drug Safety Update
    Then the Drug Safety Update should be published
    And the publish should have been logged 1 time
    And a publication notification should not have been sent
    When I am on the Drug Safety Update edit page
    And I edit the document and indicate the change is minor
    When I publish the Drug Safety Update
    Then an email alert should not be sent
    And the publish should still have been logged 1 time
