Feature: Publishing an Medical Safety Alert
  As a MHRA Editor
  I want to create a Medical Safety Alert in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a "MHRA" editor

  Scenario: can create a new Medical Safety Alert in draft
    When I create a Medical Safety Alert
    Then the Medical Safety Alert should be in draft

  Scenario: can publish a draft Medical Safety Alert
    Given a draft Medical Safety Alert exists
    When I publish the Medical Safety Alert
    Then the Medical Safety Alert should be published

  Scenario: can create a new Medical Safety Alert and publish immediately
    When I publish a new Medical Safety Alert
    Then the Medical Safety Alert should be published
    And the publish should have been logged 1 times

  Scenario: immediately republish a published Medical Safety Alert
    When I publish a new Medical Safety Alert
    When I am on the Medical Safety Alert edit page
    And I edit the document and republish
    Then the amended document should be published
    And previous editions should be archived

  Scenario: Sends an email alert on first publish
    Given a draft Medical Safety Alert exists
    When I publish the Medical Safety Alert
    Then a publication notification should have been sent

  Scenario: Cannot edit a published Medical Safety Alert without a change note
    Given a published Medical Safety Alert exists
    When I am on the Medical Safety Alert edit page
    And I edit the document without a change note
    Then I see an error requesting that I provide a change note

  Scenario: Sends an email alert on a major update and updates logs
    Given a published Medical Safety Alert exists
    Then a publication notification should have been sent
    And the publish should have been logged 1 time
    When I am on the Medical Safety Alert edit page
    And I edit the document with a change note
    And I publish the Medical Safety Alert
    Then a publication notification should have been sent
    And the publish should have been logged 2 times

  Scenario: Minor updates do not send emails or update logs
    When I publish a new Medical Safety Alert
    Then the Medical Safety Alert should be published
    And the publish should have been logged 1 time
    And a publication notification should have been sent
    When I am on the Medical Safety Alert edit page
    And I edit the document and indicate the change is minor
    When I publish the Medical Safety Alert
    Then an email alert should not be sent
    And the publish should still have been logged 1 time
