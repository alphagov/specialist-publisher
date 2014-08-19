Feature: Withdrawing a Drug Safety Update
  As a MHRA editor
  I want to withdraw a Drug Safety Update
  So that it is not accessible to the public

  Background:
    Given I am logged in as a "MHRA" editor
    And a published Drug Safety Update exists

  Scenario: Withdraw a Drug Safety Update
    When I withdraw a Drug Safety Update
    Then the Drug Safety Update should be withdrawn
