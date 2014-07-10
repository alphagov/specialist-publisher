Feature: Withdrawing a AAIB report
  As a AAIB editor
  I want to withdraw a AAIB report
  So that it is not accessible to the public

  Background:
    Given I am logged in as a "AAIB" editor
    And a published AAIB report exists

  Scenario: Withdraw a AAIB report
    When I withdraw a AAIB report
    Then the AAIB report should be withdrawn
