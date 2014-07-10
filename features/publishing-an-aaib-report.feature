Feature: Publishing an AAIB Report
  As an AAIB editor
  I want to create a new report in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a "AAIB" editor

  Scenario: can create a new AAIB Report in draft
    When I create a AAIB report
    Then the AAIB report should be in draft

  Scenario: can publish a draft AAIB Report
    Given a draft AAIB report exists
    When I publish the AAIB report
    Then the AAIB report should be published

  Scenario: can create a new AAIB report and publish immediately
    When I publish a new AAIB report
    Then the AAIB report should be published

  Scenario: immediately republish a published case
    When I publish a new AAIB report
    And I edit the AAIB report and republish
    Then the amended document should be published
    And previous editions should be archived
