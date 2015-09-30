Feature: Withdrawing an UTAAC decision
  As a UTAAC editor
  I want to withdraw an UTAAC decision
  So that it is not accessible to the public

  Background:
    Given I am logged in as a "UTAAC" editor
    And a published UTAAC decision exists

  Scenario: Withdraw an UTAAC decision
    When I withdraw an UTAAC decision
    Then the UTAAC decision should be withdrawn
