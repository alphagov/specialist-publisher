Feature: AAIB Report Attachments
  As an AAIB editor
  I want to upload an attachment to a case via the publisher
  So that users can access the supporting documents

  Background:
    Given I am logged in as a "AAIB" editor

  @javascript
  Scenario: AAIB editor can add attachment to report
    Given a draft AAIB report exists
    When I attach a file and give it a title
    Then I see the attachment on the page with its example markdown embed code
    
  Scenario: AAIB editor can replace and attachment
    Given there is a published report with an attachment
    When I edit the attachment
    Then I see the updated attachment on the document edit page

  @regression
  Scenario: AAIB editor can add and replace attachment to report
    Given a draft AAIB report exists
    When I attach a file and give it a title
    Then I see the attached file
    When I edit the attachment
    Then I see the updated attachment on the document edit page
