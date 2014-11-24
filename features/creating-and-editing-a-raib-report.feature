Feature: Publishing a RAIB Report
  As an RAIB editor
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
