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

  Scenario: immediately republish a published case
    When I publish a new Drug Safety Update
    And I edit the Drug Safety Update and republish
    Then the amended document should be published
    And previous editions should be archived
