Feature: Attachments
  As an editor
  I want to upload an attachment to a case via the publisher
  So that users can access the supporting documents

  @javascript
  Scenario: CMA editor can add attachment to case
    Given I am logged in as a "CMA" editor
    And there is an existing draft case
    When I attach a file and give it a title
    Then I see the attachment on the page with its example markdown embed code
    When I copy+paste the embed code into the body of the case
    And I preview the document
    Then I can see a link to the file with the title in the document preview
    When I edit the CMA case and republish
    Then the attachments from the previous edition remain

  Scenario: CMA editor can replace and attachment
    Given I am logged in as a "CMA" editor
    And there is a published case with an attachment
    When I edit the attachment
    Then I see the updated attachment on the document edit page

  @regression
  Scenario: CMA editor can add and replace attachment to manual
    Given I am logged in as a "CMA" editor
    And a draft manual exists without any documents
    And a draft document exists for the manual
    When I attach a file and give it a title
    Then I see the attached file
    When I edit the attachment
    Then I see the updated attachment on the document edit page

  @regression
  Scenario: GDS editor can add attachment to manual from another Org
    Given a draft manual exists belonging to "ministry-of-tea"
    And I am logged in as a "GDS" editor
    And a draft document exists for the manual
    When I attach a file and give it a title
    Then I see the attached file
    When I edit the attachment
    Then I see the updated attachment on the document edit page
