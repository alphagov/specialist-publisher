Feature: Publishing an International Development Fund
  As a DFID Editor
  I want to create international development fund pages in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a "DFID" editor

  Scenario: can create a new International Development Fund in draft
    When I create a International Development Fund
    Then the International Development Fund should be in draft

  Scenario: can publish a draft International Development Fund
    Given a draft International Development Fund exists
    When I publish the International Development Fund
    Then the International Development Fund should be published

  Scenario: can create a new International Development Fund and publish immediately
    When I publish a new International Development Fund
    Then the International Development Fund should be published
    And the publish should have been logged 1 times

  Scenario: immediately republish a published International Development Fund
    When I publish a new International Development Fund
    When I am on the International Development Fund edit page
    And I edit the document and republish
    Then the amended document should be published
    And previous editions should be archived

  Scenario: Sends an email alert on first publish
    Given a draft International Development Fund exists
    When I publish the International Development Fund
    Then a publication notification should have been sent

  Scenario: Cannot edit a published International Development Fund without a change note
    Given a published International Development Fund exists
    When I am on the International Development Fund edit page
    And I edit the document without a change note
    Then I see an error requesting that I provide a change note

  Scenario: Sends an email alert on a major update and updates logs
    Given a published International Development Fund exists
    Then a publication notification should have been sent
    And the publish should have been logged 1 time
    When I am on the International Development Fund edit page
    And I edit the document with a change note
    And I publish the International Development Fund
    Then a publication notification should have been sent
    And the publish should have been logged 2 times

  Scenario: Minor updates do not send emails or update logs
    When I publish a new International Development Fund
    Then the International Development Fund should be published
    And the publish should have been logged 1 time
    And a publication notification should have been sent
    When I am on the International Development Fund edit page
    And I edit the document and indicate the change is minor
    When I publish the International Development Fund
    Then an email alert should not be sent
    And the publish should still have been logged 1 time
