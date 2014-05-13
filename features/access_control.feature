Feature: Access control
  As a User
  I want to have access only to relevant content
  So that I can publish content on gov.uk

  Scenario: Non-CMA editor has no access to documents
    Given I am logged in as a non-CMA editor
    Then I do not see an option for editing documents

  Scenario: Non-CMA editor is sent a document URL
    Given I am logged in as a non-CMA editor
    When I attempt to visit a document edit URL
    Then I am redirected back to the index page
    And I see a message like "You do not have permission"
