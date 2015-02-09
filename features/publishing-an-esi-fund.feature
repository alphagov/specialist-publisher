Feature: Publishing an ESI Fund
As a DCLG Editor
I want to publish European Structural and Investment funds
So that they are available to the public

Background:
Given I am logged in as a "DCLG" editor

Scenario: can create a new ESI Fund in draft
  When I create an ESI Fund
  Then the ESI Fund should be in draft

Scenario: can publish a draft ESI Fund
  Given a draft ESI Fund exists
  When I publish the ESI Fund
  Then the ESI Fund should be published

Scenario: can create a new ESI Fund and publish immediately
  When I publish a new ESI Fund
  Then the ESI Fund should be published
  And the publish should have been logged 1 times

Scenario: immediately republish a published ESI Fund
  When I publish a new ESI Fund
  When I am on the ESI Fund edit page
  And I edit the document and republish
  Then the amended document should be published
  And previous editions should be archived

Scenario: Sends an email alert on first publish
  Given a draft ESI Fund exists
  When I publish the ESI Fund
  Then a publication notification should have been sent

Scenario: Cannot edit a published ESI Fund without a change note
  Given a published ESI Fund exists
  When I am on the ESI Fund edit page
  And I edit the document without a change note
  Then I see an error requesting that I provide a change note

Scenario: Sends an email alert on a major update and updates logs
  Given a published ESI Fund exists
  Then a publication notification should have been sent
  And the publish should have been logged 1 time
  When I am on the ESI Fund edit page
  And I edit the document with a change note
  And I publish the ESI Fund
  Then a publication notification should have been sent
  And the publish should have been logged 2 times

Scenario: Minor updates do not send emails or update logs
  When I publish a new ESI Fund
  Then the ESI Fund should be published
  And the publish should have been logged 1 time
  And a publication notification should have been sent
  When I am on the ESI Fund edit page
  And I edit the document and indicate the change is minor
  When I publish the ESI Fund
  Then an email alert should not be sent
  And the publish should still have been logged 1 time
