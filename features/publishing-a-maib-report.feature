Feature: Publishing a MAIB Report
  As a MAIB editor
  I want to create a new report in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a "MAIB" editor

  Scenario: can publish a draft MAIB Report
    Given a draft MAIB report exists
    When I publish the MAIB report
    Then the MAIB report should be published

  Scenario: can create a new MAIB report and publish immediately
    When I publish a new MAIB report
    Then the MAIB report should be published

  Scenario: immediately republish a published case
    When I publish a new MAIB report
    And I edit the MAIB report and republish
    Then the amended document should be published
    And previous editions should be archived

  Scenario: Minor updates do not send emails
    When I publish a new MAIB report
    Then the MAIB report should be published
    And a publication notification should have been sent
    When I edit the MAIB report and indicate the change is minor
    When I publish the MAIB report
    Then an email alert should not be sent
