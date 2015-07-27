Feature: Creating and editing an International Development Fund
  As a DFID Editor
  I want to create international development fund pages in Specialist publisher
  So that I can add them to the International Development Funds finder

  Background:
    Given I am logged in as a "DFID" editor

  Scenario: Create a new International Development Fund
    When I create a International Development Fund
    Then the International Development Fund has been created
    And the document should be sent to content preview

  Scenario: Cannot create a International Development Fund with invalid fields
    When I create a International Development Fund with invalid fields
    Then I should see error messages about missing fields
    And I should see an error message about a "Body" field containing javascript
    And the International Development Fund should not have been created

  Scenario: Cannot edit an International Development Fund without entering required fields
    Given a draft International Development Fund exists
    When I edit an International Development Fund and remove required fields
    Then the International Development Fund should not have been updated

  Scenario: Can view a list of all International Development Funds in the publisher
    Given two International Development Funds exist
    Then the International Development Funds should be in the publisher IDF index in the correct order

  Scenario: Edit a draft International Development Fund
    Given a draft International Development Fund exists
    When I edit a International Development Fund
    Then the International Development Fund should have been updated
    And the document should be sent to content preview
