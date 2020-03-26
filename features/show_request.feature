Feature: view previously submitted request

    As a User
    So that I know I can view a previosuly
    I want to have a details page about

    Background: existing requested translations

        Given I am signed in as a user

        Given the following requests exist:
            | id | user_tarjimly_id | from_language | to_language | document_text | document_format | deadline   | title                  | description | categories    | num_claims | form_type | _status |
            | 1  | 364494           | English       | Arabic      | example text  | text            | 2019-11-09 | Camp Announcment       | information | Refugee, Camp | 1          | N/A       | 0       |

        Given the following claims exist:
            | translator_tarjimly_id | _status | submitted_date | translation_text | translation_format | request_id |
            | 364495                 | 0       | Arabic         | example text     | text               | 1          |

    Scenario: visiting request's details page
        Given I go to the "Requests" page
        When I click button "View" from the list of request
        Then I should see "information"
        Then I should see "English" and "Arabic"

    Scenario: return to all requests
        Given I go to the "Requests" page
        When I click button "View" from the list of request
        When I select "Back to All Requests"
        Then I should be on the "/requests" path

    Scenario: if request has been deleted will display 404 not found page
        Given I go to the "Show" page
        Then I should see "You are not authorized to view this request!"

