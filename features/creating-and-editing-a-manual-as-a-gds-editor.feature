Feature: Creating and editing manuals
  As a GDS editor
  I want to create manuals for my own organisation
  And edit manuals belonging to any organisation

  Scenario: Create a new manual
    Given I am logged in as a "GDS" editor
    When I create a manual
    Then the manual should exist
    And the manual should belong to "government-digital-service"

  Scenario: Edit a draft manual
    Given a draft manual exists belonging to "ministry-of-tea"
    And I am logged in as a "GDS" editor
    When I edit a manual
    Then the manual should have been updated
    And the manual should still belong to "ministry-of-tea"
