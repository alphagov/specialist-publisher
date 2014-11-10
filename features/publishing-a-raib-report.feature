Feature: Publishing a RAIB Report
  As a RAIB editor
  I want to create a new report in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a "RAIB" editor

  Scenario: can publish a draft RAIB Report
    Given a draft RAIB report exists
    When I publish the RAIB report
    Then the RAIB report should be published

  Scenario: can create a new RAIB report and publish immediately
    When I publish a new RAIB report
    Then the RAIB report should be published

  Scenario: immediately republish a published case
    When I publish a new RAIB report
    And I edit the RAIB report and republish
    Then the amended document should be published
    And previous editions should be archived

  Scenario: Minor updates do not send emails
    When I publish a new RAIB report
    Then the RAIB report should be published
    And a publication notification should have been sent
    When I edit the RAIB report and indicate the change is minor
    When I publish the RAIB report
    Then an email alert should not be sent
