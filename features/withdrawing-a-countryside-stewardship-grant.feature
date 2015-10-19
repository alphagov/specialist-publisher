Feature: Withdrawing a Countryside Stewardship Grant
As a NE editor
I want to withdraw a Countryside Stewardship Grant
So that it is not accessible to the public

Background:
Given I am logged in as a "NE" editor
And a published Countryside Stewardship Grant exists

Scenario: Withdraw a Countryside Stewardship Grant
  When I withdraw a Countryside Stewardship Grant
  Then the Countryside Stewardship Grant should be withdrawn
