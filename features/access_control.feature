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
    And I see a message like "You don't have permission to do that"

  Scenario: Editor only sees manuals created by their organisation
    Given there are manuals created by multiple organisations
    And I am logged in as a non-CMA editor
    When I view my list of manuals
    Then I only see manuals created by my organisation

  Scenario: GDS Editor sees manuals created by all organisations
    Given there are manuals created by multiple organisations
    And I am logged in as a "GDS" editor
    When I view my list of manuals
    Then I see manuals created by all organisations

  Scenario: Writers
    Given I am logged in as a writer
    Then I can edit cases and manuals
    And I cannot publish cases nor manuals
    And I cannot withdraw cases
