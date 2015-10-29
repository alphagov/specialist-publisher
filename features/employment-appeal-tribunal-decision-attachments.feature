Feature: employment appeal tribunal decision attachments
  As an EmploymentAppealTribunal editor
  I want to upload an attachment to a case via the publisher
  So that users can access the decision documents

  Background:
    Given I am logged in as a "EmploymentAppealTribunal" editor

  @javascript
  Scenario: EmploymentAppealTribunal editor can add attachment to report
    Given a draft employment appeal tribunal decision exists
    When I attach a file and give it a title
    Then I see the attachment on the page with its example markdown embed code

  Scenario: EmploymentAppealTribunal editor can replace and attachment
    Given there is a published employment appeal tribunal decision with an attachment
    When I edit the attachment
    Then I see the updated attachment on the document edit page

  @regression
  Scenario: EmploymentAppealTribunal editor can add and replace attachment to report
    Given a draft employment appeal tribunal decision exists
    When I attach a file and give it a title
    Then I see the attached file
    When I edit the attachment
    Then I see the updated attachment on the document edit page
