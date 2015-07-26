Feature: Creating and editing an ESI Fund
As a DCLG Editor
I want to create ESI Funds pages in Specialist publisher
So that I can add them to the ESI Funds finder

Background:
Given I am logged in as a "DCLG" editor

Scenario: Create a new ESI Fund
  When I create an ESI Fund
  Then the ESI Fund has been created
  And the document should be sent to content preview

Scenario: Cannot create an ESI Fund with invalid fields
  When I create an ESI Fund with invalid fields
  Then I should see error messages about missing fields
  And I should see an error message about an invalid date field "Closing date"
  And I should see an error message about a "Body" field containing javascript
  And the ESI Fund should not have been created

Scenario: Cannot edit an ESI Fund without entering required fields
  Given a draft ESI Fund exists
  When I edit an ESI Fund and remove required fields
  Then the ESI Fund should not have been updated

Scenario: Can view a list of all ESI Funds in the publisher
  Given two ESI Funds exist
  Then the ESI Funds should be in the publisher CSG index in the correct order

Scenario: Edit a draft ESI Fund
  Given a draft ESI Fund exists
  When I edit an ESI Fund
  Then the ESI Fund should have been updated
  And the document should be sent to content preview
