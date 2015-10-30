Feature: Withdrawing an employment tribunal decision
  As a EmploymentTribunal editor
  I want to withdraw an employment tribunal decision
  So that it is not accessible to the public

  Background:
    Given I am logged in as a "EmploymentTribunal" editor
    And a published employment tribunal decision exists

  Scenario: Withdraw an employment tribunal decision
    When I withdraw an employment tribunal decision
    Then the employment tribunal decision should be withdrawn
