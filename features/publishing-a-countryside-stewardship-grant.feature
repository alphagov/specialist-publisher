Feature: Publishing a Countryside Stewardship Grant
As a NE Editor
I want to create countryside stewardship fund pages in draft
So that I can prepare the info for publication

Background:
Given I am logged in as a "NE" editor

Scenario: can create a new Countryside Stewardship Grant in draft
  When I create a Countryside Stewardship Grant
  Then the Countryside Stewardship Grant should be in draft

Scenario: can publish a draft Countryside Stewardship Grant
  Given a draft Countryside Stewardship Grant exists
  When I publish the Countryside Stewardship Grant
  Then the Countryside Stewardship Grant should be published

Scenario: can create a new Countryside Stewardship Grant and publish immediately
  When I publish a new Countryside Stewardship Grant
  Then the Countryside Stewardship Grant should be published
  And the publish should have been logged 1 times

Scenario: immediately republish a published Countryside Stewardship Grant
  When I publish a new Countryside Stewardship Grant
  When I am on the Countryside Stewardship Grant edit page
  And I edit the document and republish
  Then the amended document should be published
  And previous editions should be archived

Scenario: Sends an email alert on first publish
  Given a draft Countryside Stewardship Grant exists
  When I publish the Countryside Stewardship Grant
  Then a publication notification should have been sent

Scenario: Cannot edit a published Countryside Stewardship Grant without a change note
  Given a published Countryside Stewardship Grant exists
  When I am on the Countryside Stewardship Grant edit page
  And I edit the document without a change note
  Then I see an error requesting that I provide a change note

Scenario: Sends an email alert on a major update and updates logs
  Given a published Countryside Stewardship Grant exists
  Then a publication notification should have been sent
  And the publish should have been logged 1 time
  When I am on the Countryside Stewardship Grant edit page
  And I edit the document with a change note
  And I publish the Countryside Stewardship Grant
  Then a publication notification should have been sent
  And the publish should have been logged 2 times

Scenario: Minor updates do not send emails or update logs
  When I publish a new Countryside Stewardship Grant
  Then the Countryside Stewardship Grant should be published
  And the publish should have been logged 1 time
  And a publication notification should have been sent
  When I am on the Countryside Stewardship Grant edit page
  And I edit the document and indicate the change is minor
  When I publish the Countryside Stewardship Grant
  Then an email alert should not be sent
  And the publish should still have been logged 1 time
