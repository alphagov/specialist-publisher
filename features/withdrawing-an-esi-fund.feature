Feature: Withdrawing an ESI Fund
As a DCLG editor
I want to withdraw an ESI Fund
So that it is not accessible to the public

Background:
Given I am logged in as a "DCLG" editor
And a published ESI Fund exists

Scenario: Withdraw an ESI Fund
  When I withdraw an ESI Fund
  Then the ESI Fund should be withdrawn
