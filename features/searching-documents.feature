Feature: Searching specialist documents
  As an editor
  I want to search my specialist documents
  So that I can find a specific document to edit

  Background:
    Given I am logged in as a "AAIB" editor
    And multiple draft AAIB reports exist

  Scenario: Can search by exact slug
    When I search for an exact slug
    Then I see the matching AAIB reports in the list

  Scenario: Can search by partial slug
    When I search for a partial slug
    Then I see the matching AAIB reports in the list

  Scenario: Can search by title
    When I search for a partial title
    Then I see the matching AAIB reports in the list

  Scenario: Can ignore case when searching
    When I search for a partial title in the wrong case
    Then I see the matching AAIB reports in the list

  Scenario: Can clear the search
    Given a search has been performed
    When I clear the search field
    Then I see all AAIB reports in the list
