Feature: employment tribunal decision attachments
  As an EmploymentTribunal editor
  I want to upload an attachment to a case via the publisher
  So that users can access the decision documents

  Background:
    Given I am logged in as a "EmploymentTribunal" editor

  @javascript
  Scenario: EmploymentTribunal editor can add attachment to report
    Given a draft employment tribunal decision exists
    When I attach a file and give it a title
    Then I see the attachment on the page with its example markdown embed code

  Scenario: EmploymentTribunal editor can replace and attachment
    Given there is a published employment tribunal decision with an attachment
    When I edit the attachment
    Then I see the updated attachment on the document edit page

  @regression
  Scenario: EmploymentTribunal editor can add and replace attachment to report
    Given a draft employment tribunal decision exists
    When I attach a file and give it a title
    Then I see the attached file
    When I edit the attachment
    Then I see the updated attachment on the document edit page
