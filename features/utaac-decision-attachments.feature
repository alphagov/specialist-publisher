Feature: UTAAC decision attachments
  As an UTAAC editor
  I want to upload an attachment to a case via the publisher
  So that users can access the decision documents

  Background:
    Given I am logged in as a "UTAAC" editor

  @javascript
  Scenario: UTAAC editor can add attachment to report
    Given a draft UTAAC decision exists
    When I attach a file and give it a title
    Then I see the attachment on the page with its example markdown embed code

  Scenario: UTAAC editor can replace and attachment
    Given there is a published UTAAC decision with an attachment
    When I edit the attachment
    Then I see the updated attachment on the document edit page

  @regression
  Scenario: UTAAC editor can add and replace attachment to report
    Given a draft UTAAC decision exists
    When I attach a file and give it a title
    Then I see the attached file
    When I edit the attachment
    Then I see the updated attachment on the document edit page
