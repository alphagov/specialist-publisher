Feature: Creating and editing a manual
  As a CMA editor
  I want to create and edit a manual and see it in the publisher
  So that I can start moving my content to gov.uk

  Background:
    Given I am logged in as a CMA editor

  Scenario: Create a new manual
    When I create a manual
    Then the manual should exist

  Scenario: Edit a draft manual
    Given a draft manual exists
    When I edit a manual
    Then the manual should have been updated

  Scenario: Try to create an invalid manual
    When I create a manual with an empty title
    Then I see errors for the title field
