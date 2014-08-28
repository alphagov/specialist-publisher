Feature: Publishing an Medical Safety Alert
  As a MHRA Editor
  I want to create a Medical Safety Alert in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a "MHRA" editor

  Scenario: can create a new Medical Safety Alert in draft
    When I create a Medical Safety Alert
    Then the Medical Safety Alert should be in draft

  Scenario: can publish a draft Medical Safety Alert
    Given a draft Medical Safety Alert exists
    When I publish the Medical Safety Alert
    Then the Medical Safety Alert should be published

  Scenario: can create a new Medical Safety Alert and publish immediately
    When I publish a new Medical Safety Alert
    Then the Medical Safety Alert should be published

  Scenario: immediately republish a published case
    When I publish a new Medical Safety Alert
    And I edit the Medical Safety Alert and republish
    Then the amended document should be published
    And previous editions should be archived
