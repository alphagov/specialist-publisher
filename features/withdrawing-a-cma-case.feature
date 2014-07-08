Feature: Withdrawing a CMA case
  As a CMA editor
  I want to withdraw a CMA case
  So that it is not accessible to the public

  Background:
    Given I am logged in as a "CMA" editor
    And a published CMA case exists

  Scenario: Withdraw a CMA case
    When I withdraw a CMA case
    Then the CMA case should be withdrawn
