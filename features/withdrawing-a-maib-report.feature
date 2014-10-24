Feature: Withdrawing a MAIB report
  As a MAIB editor
  I want to withdraw a MAIB report
  So that it is not accessible to the public

  Background:
    Given I am logged in as a "MAIB" editor
    And a published MAIB report exists

  Scenario: Withdraw a MAIB report
    When I withdraw a MAIB report
    Then the MAIB report should be withdrawn
