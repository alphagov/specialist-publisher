Feature: Withdrawing an asylum support decision
  As a AST editor
  I want to withdraw an asylum support decision
  So that it is not accessible to the public

  Background:
    Given I am logged in as a "AST" editor
    And a published asylum support decision exists

  Scenario: Withdraw an asylum support decision
    When I withdraw an asylum support decision
    Then the asylum support decision should be withdrawn
