Feature: Publishing a CMA case
  As a CMA editor
  I want to create a new case in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a "CMA" editor

  Scenario: can create a new CMA case in draft
    When I create a CMA case
    Then the CMA case should be in draft

  Scenario: can publish a draft CMA case
    Given a draft CMA case exists
    When I publish the CMA case
    Then the CMA case should be published

  Scenario: can create a new CMA case and publish immediately
    When I publish a new CMA case
    Then the CMA case should be published

  Scenario: immediately republish a published case
    When I publish a new CMA case
    When I am on the CMA case edit page
    And I edit the document and republish
    Then the amended document should be published
    And previous editions should be archived

  Scenario: Sends an email alert on first publish
    Given a draft CMA case exists
    When I publish the CMA case
    Then a publication notification should have been sent

  Scenario: Cannot edit a published CMA case without a change note
    Given a published CMA case exists
    When I am on the CMA case edit page
    And I edit the document without a change note
    Then I see an error requesting that I provide a change note

  Scenario: Sends an email alert on a major update
    Given a published CMA case exists
    Then a publication notification should have been sent
    When I am on the CMA case edit page
    And I edit the document with a change note
    And I publish the CMA case
    Then a publication notification should have been sent

  Scenario: Minor updates do not send emails
    When I publish a new CMA case
    Then the CMA case should be published
    And a publication notification should have been sent
    When I am on the CMA case edit page
    And I edit the document and indicate the change is minor
    When I publish the CMA case
    Then an email alert should not be sent
