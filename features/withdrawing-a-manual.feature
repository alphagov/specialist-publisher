Feature: Script to withdraw published manuals
  As a DevOps specialist
  I want to withdraw a manual
  So that it is not accessible to the public

  Scenario:
    Given a published manual with at least two sections exists
    When a DevOps specialist withdraws the manual for me
    Then the manual should be withdrawn
