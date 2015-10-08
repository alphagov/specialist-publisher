Feature: Publishing a tax tribunal decision
  As an TaxTribunal editor
  I want to create a new report in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a "TaxTribunal" editor

  Scenario: can publish a draft tax tribunal decision
    Given a draft tax tribunal decision exists
    When I publish the tax tribunal decision
    Then the tax tribunal decision should be published

  Scenario: can create a new tax tribunal decision and publish immediately
    When I publish a new tax tribunal decision
    Then the tax tribunal decision should be published
    And the publish should have been logged 1 times

  Scenario: immediately republish a published tax tribunal decision
    When I publish a new tax tribunal decision
    When I am on the tax tribunal decision edit page
    And I edit the document and republish
    Then the amended document should be published
    And previous editions should be archived

  Scenario: Sends an email alert on first publish
    Given a draft tax tribunal decision exists
    When I publish the tax tribunal decision
    Then a publication notification should have been sent

  Scenario: Cannot edit a published tax tribunal decision without a change note
    Given a published tax tribunal decision exists
    When I am on the tax tribunal decision edit page
    And I edit the document without a change note
    Then I see an error requesting that I provide a change note

  Scenario: Sends an email alert on a major update and updates logs
    Given a published tax tribunal decision exists
    Then a publication notification should have been sent
    And the publish should have been logged 1 time
    When I am on the tax tribunal decision edit page
    And I edit the document with a change note
    And I publish the tax tribunal decision
    Then a publication notification should have been sent
    And the publish should have been logged 2 times

  Scenario: Minor updates do not send emails or update logs
    When I publish a new tax tribunal decision
    Then the tax tribunal decision should be published
    And the publish should have been logged 1 time
    And a publication notification should have been sent
    When I am on the tax tribunal decision edit page
    And I edit the document and indicate the change is minor
    When I publish the tax tribunal decision
    Then an email alert should not be sent
    And the publish should still have been logged 1 time
