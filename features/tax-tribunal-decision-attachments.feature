Feature: tax tribunal decision attachments
  As an TaxTribunal editor
  I want to upload an attachment to a case via the publisher
  So that users can access the decision documents

  Background:
    Given I am logged in as a "TaxTribunal" editor

  @javascript
  Scenario: TaxTribunal editor can add attachment to report
    Given a draft tax tribunal decision exists
    When I attach a file and give it a title
    Then I see the attachment on the page with its example markdown embed code

  Scenario: TaxTribunal editor can replace and attachment
    Given there is a published tax tribunal decision with an attachment
    When I edit the attachment
    Then I see the updated attachment on the document edit page

  @regression
  Scenario: TaxTribunal editor can add and replace attachment to report
    Given a draft tax tribunal decision exists
    When I attach a file and give it a title
    Then I see the attached file
    When I edit the attachment
    Then I see the updated attachment on the document edit page
