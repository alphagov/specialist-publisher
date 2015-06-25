Feature: Withdrawing a RAIB report
  As a RAIB editor
  I want to withdraw a RAIB report
  So that it is not accessible to the public

  Background:
    Given I am logged in as a "RAIB" editor
    And a published RAIB report exists

  Scenario: Withdraw a RAIB report
    When I withdraw a RAIB report
    Then the RAIB report should be withdrawn
