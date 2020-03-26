Feature: create a new request

  So that I can create a translation request and provide context to translators
  I want to be able to select a From and a To language, add a title, description
  and select pre-determined categories (required)

  Background: go to new request page
    Given I am signed in as a user
    Given I click the "New Request" button

  Scenario: successfully create a new request
    When I fill in "request_document_text" with "Cucumber Test Text"
    And I select "English" from "request_from_language"
    And I select "Afar" from "request_to_language"
    And I fill in "request_deadline" with "03/25/2020 11:04 AM"
    And I fill in "request_title" with "Cucumber Test Title"
    And I fill in "request_description" with "Cucumber Test Description"
    And I click the "Create Request" button
    Then I should be on the "/requests" path
    And I should see "Cucumber Test Title"

  Scenario: forget to fill in a field
    When I fill in "request_title" with "Cucumber Test Request"
    And I click the "Create Request" button
    Then I should be on the "/requests" path

# Scenario: upload a file
#   When I select "Upload File Instead"
#   And I fill in "request_title" with "Cucumber Upload Test Request"
#   And I fill in "request_description" with "Cucumber Test Description"
#   And I upload a test file to "request_document_uploads"
#   And I select "English" from "request_from_language"
#   And I select "Arabic" from "request_to_language"
#   And I fill in "request_deadline" with "2097-08-08"
#   And I check "request_categories_legal"
#   And I click the "Create Request" button

