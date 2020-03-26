Feature: get the correct number of days

  As a Translator
  So that I know what submission dates are
  I want to see the correct date

  Background: existing requested translations

    Given I am signed in as a translator

    Given the following requests exist:
      | id | user_tarjimly_id | from_language | to_language | document_text | document_format | deadline   | title                  | description | categories    | num_claims | form_type | _status |
      | 1  | 364494           | English       | Arabic      | example text  | text            | 2018-11-09 | Old Doc                | information | Refugee, Camp | 1          | N/A       | 0       |
      | 2  | 364494           | English       | Arabic      | example text  | text            | 2090-11-09 | New Doc                | information | Refugee, Camp | 1          | N/A       | 0       |

    Given the following claims exist:
      | translator_tarjimly_id | _status | submitted_date     | translation_text | translation_format | request_id |
      | 364495                 | 0       | 2018-11-09         | example text     | text               | 1          |
      | 364495                 | 0       | 2018-11-09         | example text     | text               | 2          |

  Scenario: check the previous dates
    Given I go to the "Claims" page
    Then I should see "November"