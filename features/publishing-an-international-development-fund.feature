Feature: Publishing an International Development Fund
  As a DFID Editor
  I want to create international development fund pages in draft
  So that I can prepare the info for publication

  Background:
    Given I am logged in as a "DFID" editor

  Scenario: can create a new International Development Fund in draft
    When I create a International Development Fund
    Then the International Development Fund should be in draft

  Scenario: can publish a draft International Development Fund
    Given a draft International Development Fund exists
    When I publish the International Development Fund
    Then the International Development Fund should be published

  Scenario: can create a new International Development Fund and publish immediately
    When I publish a new International Development Fund
    Then the International Development Fund should be published

  Scenario: immediately republish a published case
    When I publish a new International Development Fund
    And I edit the International Development Fund and republish
    Then the amended document should be published
    And previous editions should be archived

  Scenario: Minor updates do not send emails
    When I publish a new International Development Fund
    Then the International Development Fund should be published
    And a publication notification should have been sent
    When I edit the International Development Fund and indicate the change is minor
    When I publish the International Development Fund
    Then an email alert should not be sent
