Feature: Publishing an MAIB Report
  As an MAIB editor
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
