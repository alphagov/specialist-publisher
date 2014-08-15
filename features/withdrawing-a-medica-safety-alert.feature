Feature: Withdrawing a Medical Safety Alert
  As a MHRA editor
  I want to withdraw a Medical Safety Alert
  So that it is not accessible to the public

  Background:
    Given I am logged in as a "MHRA" editor
    And a published Medical Safety Alert exists

  Scenario: Withdraw a Medical Safety Alert
    When I withdraw a Medical Safety Alert
    Then the Medical Safety Alert should be withdrawn
