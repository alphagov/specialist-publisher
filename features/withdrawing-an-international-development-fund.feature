Feature: Withdrawing a International Development Fund
  As a DFID editor
  I want to withdraw a International Development Fund
  So that it is not accessible to the public

  Background:
    Given I am logged in as a "DFID" editor
    And a published International Development Fund exists

  Scenario: Withdraw a International Development Fund
    When I withdraw a International Development Fund
    Then the International Development Fund should be withdrawn
