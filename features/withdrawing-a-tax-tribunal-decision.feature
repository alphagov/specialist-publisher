Feature: Withdrawing a tax tribunal decision
  As a TaxTribunal editor
  I want to withdraw a tax tribunal decision
  So that it is not accessible to the public

  Background:
    Given I am logged in as a "TaxTribunal" editor
    And a published tax tribunal decision exists

  Scenario: Withdraw a tax tribunal decision
    When I withdraw a tax tribunal decision
    Then the tax tribunal decision should be withdrawn
