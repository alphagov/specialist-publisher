Feature: Attachments
  As a CMA editor
  I want to upload an attachment to a case via the publisher
  So that users can access the supporting documents

  Background:
    Given I am logged in as a CMA editor

  Scenario: CMA editor can add attachment to case
    Given there is an existing draft case
    When I attach a file and give it a title
    Then I see the attachment on the case with its example markdown embed code
    When I copy+paste the embed code into the body of the case
    Then I can see a link to the file with the title in the document preview
