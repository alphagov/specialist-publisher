Feature: Creating and editing a CMA case
  As a CMA editor
  I want to create and edit a case and see it in the publisher
  So that I can start moving my content to gov.uk

  Background:
    Given I am logged in as a CMA editor

  Scenario: Create a new CMA case
    When I create a CMA case
    Then the CMA case should exist
