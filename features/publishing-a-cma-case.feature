Feature: Creating and editing a CMA case
  As a CMA editor
  I want to create a new case in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a CMA editor

  Scenario: can create a new CMA case in draft
    When I create a CMA case
    Then the CMA case should be in draft

  Scenario: can publish a draft CMA case
    Given a CMA case exists in draft
    When I publish the CMA case
    Then the CMA case should be published
