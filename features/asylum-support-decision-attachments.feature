Feature: asylum support decision attachments
  As an AST editor
  I want to upload an attachment to a case via the publisher
  So that users can access the decision documents

  Background:
    Given I am logged in as a "AST" editor

  @javascript
  Scenario: AST editor can add attachment to report
    Given a draft asylum support decision exists
    When I attach a file and give it a title
    Then I see the attachment on the page with its example markdown embed code

  Scenario: AST editor can replace and attachment
    Given there is a published asylum support decision with an attachment
    When I edit the attachment
    Then I see the updated attachment on the document edit page

  @regression
  Scenario: AST editor can add and replace attachment to report
    Given a draft asylum support decision exists
    When I attach a file and give it a title
    Then I see the attached file
    When I edit the attachment
    Then I see the updated attachment on the document edit page
