Feature: Withdrawing an employment appeal tribunal decision
  As a EmploymentAppealTribunal editor
  I want to withdraw an employment appeal tribunal decision
  So that it is not accessible to the public

  Background:
    Given I am logged in as a "EmploymentAppealTribunal" editor
    And a published employment appeal tribunal decision exists

  Scenario: Withdraw an employment appeal tribunal decision
    When I withdraw an employment appeal tribunal decision
    Then the employment appeal tribunal decision should be withdrawn
